#===============================================================================
# Actualizador de Pokémon NG Chronicles
#===============================================================================
# Lo lanza el propio juego desde "Comprobar actualizaciones" del menú principal.
#
#   -Accion comprobar    Mira si hay una versión nueva publicada en GitHub y deja
#                        el resultado en update\estado.txt para que el juego lo lea.
#   -Accion actualizar   Descarga solo los archivos que han cambiado, los instala
#                        y vuelve a abrir el juego.
#   -Accion reparar      Como actualizar, pero comprobando todos los archivos uno
#                        a uno (para instalaciones dañadas).
#
# Las partidas guardadas no se tocan: solo se modifican los archivos que
# aparecen en la lista de la versión (update\manifest.txt).
#===============================================================================
param(
  [ValidateSet('comprobar', 'actualizar', 'reparar')]
  [string]$Accion = 'actualizar',
  [int]$PidJuego = 0,
  [switch]$Forzar,
  [switch]$NoAbrirJuego,
  [switch]$SinPausa
)

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

$DirUpdate       = $PSScriptRoot
$Raiz            = Split-Path -Parent $DirUpdate
$ArchivoEstado   = Join-Path $DirUpdate 'estado.txt'
$ArchivoConfig   = Join-Path $DirUpdate 'config.json'
$ArchivoLista    = Join-Path $DirUpdate 'manifest.txt'
$ArchivoVersion  = Join-Path $Raiz 'version.json'
$DirTemporal     = Join-Path $DirUpdate 'tmp'
$RutaLista       = 'update/manifest.txt'
$RutaVersion     = 'version.json'
$DescargasALaVez = 8
$Intentos        = 4
$Utf8            = New-Object System.Text.UTF8Encoding($false)

Add-Type -AssemblyName System.Net.Http
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
[Net.ServicePointManager]::DefaultConnectionLimit = 16
$Cliente = New-Object System.Net.Http.HttpClient
$Cliente.Timeout = [TimeSpan]::FromMinutes(15)
$Cliente.DefaultRequestHeaders.UserAgent.ParseAdd('NGChronicles-Updater/1.0')

#-------------------------------------------------------------------------------
# Utilidades
#-------------------------------------------------------------------------------
class ErrorActualizador : System.Exception {
  ErrorActualizador([string]$mensaje) : base($mensaje) {}
}

function Escribir-Estado($datos) {
  $lineas = foreach ($clave in $datos.Keys) {
    $valor = [string]$datos[$clave] -replace '[\r\n\t]+', ' ' -replace '\\', '/'
    "$clave=$valor"
  }
  $temporal = "$ArchivoEstado.tmp"
  [IO.File]::WriteAllText($temporal, ($lineas -join "`n") + "`n", $Utf8)
  Move-Item -LiteralPath $temporal -Destination $ArchivoEstado -Force
}

function Leer-Config {
  if (-not (Test-Path -LiteralPath $ArchivoConfig)) {
    throw [ErrorActualizador]::new('Falta el archivo update\config.json. Todavía no se ha publicado ninguna versión del juego.')
  }
  $config = [IO.File]::ReadAllText($ArchivoConfig, $Utf8) | ConvertFrom-Json
  if (-not $config.repo) { throw [ErrorActualizador]::new('update\config.json no indica el repositorio de GitHub.') }
  $base = 'https://raw.githubusercontent.com'
  if ($config.urlBase) { $base = ([string]$config.urlBase).TrimEnd('/') }
  $rama = 'main'
  if ($config.rama) { $rama = [string]$config.rama }
  return @{ Repo = [string]$config.repo; Rama = $rama; Carpeta = ([string]$config.carpeta).Trim('/'); Base = $base }
}

# Dirección de un archivo del juego en una rama o etiqueta del repositorio
function Url-De($config, [string]$referencia, [string]$ruta) {
  $completa = $ruta
  if ($config.Carpeta) { $completa = $config.Carpeta + '/' + $ruta }
  $partes = $completa.Split('/') | ForEach-Object { [Uri]::EscapeDataString($_) }
  return '{0}/{1}/{2}/{3}' -f $config.Base, $config.Repo, [Uri]::EscapeDataString($referencia), ($partes -join '/')
}

# Devuelve los bytes, o $null si el archivo no existe en el repositorio (404)
function Descargar-Bytes([string]$url) {
  $ultimoError = $null
  for ($i = 1; $i -le $Intentos; $i++) {
    try {
      $respuesta = $Cliente.GetAsync($url).GetAwaiter().GetResult()
      if ([int]$respuesta.StatusCode -eq 404) { return $null }
      [void]$respuesta.EnsureSuccessStatusCode()
      return , $respuesta.Content.ReadAsByteArrayAsync().GetAwaiter().GetResult()
    } catch {
      $ultimoError = $_
      Start-Sleep -Seconds ($i * 2)
    }
  }
  throw [ErrorActualizador]::new("No se pudo conectar con GitHub. Comprueba tu conexión a internet. ($($ultimoError.Exception.GetBaseException().Message))")
}

# Mismo identificador que usa git para el contenido de un archivo
function Sha-DeBytes([byte[]]$bytes) {
  $sha = [Security.Cryptography.SHA1]::Create()
  try {
    $cabecera = [Text.Encoding]::ASCII.GetBytes("blob $($bytes.Length)`0")
    [void]$sha.TransformBlock($cabecera, 0, $cabecera.Length, $null, 0)
    [void]$sha.TransformFinalBlock($bytes, 0, $bytes.Length)
    return ([BitConverter]::ToString($sha.Hash) -replace '-', '').ToLower()
  } finally { $sha.Dispose() }
}

function Sha-DeArchivo([string]$ruta) {
  $sha = [Security.Cryptography.SHA1]::Create()
  $flujo = [IO.File]::Open($ruta, 'Open', 'Read', 'ReadWrite')
  try {
    $cabecera = [Text.Encoding]::ASCII.GetBytes("blob $($flujo.Length)`0")
    [void]$sha.TransformBlock($cabecera, 0, $cabecera.Length, $null, 0)
    $bloque = New-Object byte[] 1048576
    while (($leidos = $flujo.Read($bloque, 0, $bloque.Length)) -gt 0) {
      [void]$sha.TransformBlock($bloque, 0, $leidos, $null, 0)
    }
    [void]$sha.TransformFinalBlock($bloque, 0, 0)
    return ([BitConverter]::ToString($sha.Hash) -replace '-', '').ToLower()
  } finally { $flujo.Dispose(); $sha.Dispose() }
}

# Cada línea de la lista es: identificador <tab> tamaño <tab> ruta
function Leer-Lista([string]$texto) {
  $lista = New-Object 'System.Collections.Generic.Dictionary[string,object]' ([StringComparer]::OrdinalIgnoreCase)
  foreach ($linea in $texto.Split("`n")) {
    $linea = $linea.TrimEnd("`r")
    if (-not $linea) { continue }
    $campos = $linea.Split("`t", 3)
    if ($campos.Length -ne 3 -or $campos[0] -notmatch '^[0-9a-f]{40}$') { continue }
    $ruta = $campos[2]
    # Nunca se escribe fuera de la carpeta del juego
    if ($ruta -match '(^|/)\.\.(/|$)' -or $ruta -match '^[/\\]' -or $ruta -match '[:\\]') { continue }
    $lista[$ruta] = @{ Sha = $campos[0]; Tamano = [long]$campos[1]; Ruta = $ruta }
  }
  return $lista
}

function Ruta-Local([string]$ruta) {
  return Join-Path $Raiz ($ruta -replace '/', '\')
}

function Version-Local {
  if (-not (Test-Path -LiteralPath $ArchivoVersion)) { return '0' }
  try { return [string]([IO.File]::ReadAllText($ArchivoVersion, $Utf8) | ConvertFrom-Json).version } catch { return '0' }
}

# Devuelve 1 si $a es más nueva que $b, -1 si es más vieja y 0 si son iguales
function Comparar-Versiones([string]$a, [string]$b) {
  $pa = @([regex]::Matches($a, '\d+') | ForEach-Object { [long]$_.Value })
  $pb = @([regex]::Matches($b, '\d+') | ForEach-Object { [long]$_.Value })
  for ($i = 0; $i -lt [Math]::Max($pa.Count, $pb.Count); $i++) {
    $na = 0; if ($i -lt $pa.Count) { $na = $pa[$i] }
    $nb = 0; if ($i -lt $pb.Count) { $nb = $pb[$i] }
    if ($na -gt $nb) { return 1 }
    if ($na -lt $nb) { return -1 }
  }
  return 0
}

function Texto-Tamano([long]$bytes) {
  if ($bytes -ge 1MB) { return '{0:N1} MB' -f ($bytes / 1MB) }
  return '{0:N0} KB' -f [Math]::Ceiling($bytes / 1KB)
}

function Es-CopiaDeDesarrollo {
  return (Test-Path -LiteralPath (Join-Path $Raiz '.git')) -or (Test-Path -LiteralPath (Join-Path (Split-Path -Parent $Raiz) '.git'))
}

#-------------------------------------------------------------------------------
# Consulta la última versión publicada y calcula qué habría que descargar
#-------------------------------------------------------------------------------
function Obtener-Plan([bool]$revisarTodo) {
  $config = Leer-Config
  $local = Version-Local
  $plan = @{ Config = $config; Local = $local; Remota = $null; HayNueva = $false; Descargar = @(); Borrar = @(); Bytes = [long]0 }

  $bytesVersion = Descargar-Bytes ((Url-De $config $config.Rama $RutaVersion) + '?t=' + [DateTime]::UtcNow.Ticks)
  if ($null -eq $bytesVersion) { return $plan }
  $remota = $Utf8.GetString($bytesVersion) | ConvertFrom-Json
  $plan.Remota = [string]$remota.version
  $plan.Notas = [string]$remota.notas
  $plan.BytesVersion = $bytesVersion
  $plan.HayNueva = (Comparar-Versiones $plan.Remota $local) -gt 0
  if (-not $plan.HayNueva -and -not $revisarTodo) { return $plan }

  $etiqueta = 'v' + $plan.Remota
  $bytesLista = Descargar-Bytes (Url-De $config $etiqueta $RutaLista)
  if ($null -eq $bytesLista) {
    throw [ErrorActualizador]::new("La versión $($plan.Remota) todavía no está disponible para descargar. Inténtalo de nuevo en unos minutos.")
  }
  $plan.Etiqueta = $etiqueta
  $plan.BytesLista = $bytesLista
  $listaRemota = Leer-Lista ($Utf8.GetString($bytesLista))
  if ($listaRemota.Count -eq 0) { throw [ErrorActualizador]::new('La lista de archivos de la nueva versión está vacía o dañada.') }

  $listaLocal = $null
  if (-not $revisarTodo -and (Test-Path -LiteralPath $ArchivoLista)) {
    $listaLocal = Leer-Lista ([IO.File]::ReadAllText($ArchivoLista, $Utf8))
    if ($listaLocal.Count -eq 0) { $listaLocal = $null }
  }
  $plan.RevisionCompleta = ($null -eq $listaLocal)

  $descargar = New-Object System.Collections.Generic.List[object]
  $revisados = 0
  foreach ($entrada in $listaRemota.Values) {
    $destino = Ruta-Local $entrada.Ruta
    if ($plan.RevisionCompleta -and $Accion -ne 'comprobar' -and (++$revisados % 1000) -eq 0) {
      Write-Host "  Revisando archivos... $revisados de $($listaRemota.Count)"
    }
    if ($null -ne $listaLocal) {
      # Con la lista de la versión instalada basta comparar identificadores
      $anterior = $null
      if ($listaLocal.TryGetValue($entrada.Ruta, [ref]$anterior) -and $anterior.Sha -eq $entrada.Sha -and (Test-Path -LiteralPath $destino)) { continue }
    } elseif ($Accion -eq 'comprobar') {
      # Sin lista local no se puede saber sin revisar todo; eso se deja para la descarga
      continue
    }
    if (Test-Path -LiteralPath $destino) {
      $archivo = Get-Item -LiteralPath $destino -Force
      if ($archivo.Length -eq $entrada.Tamano -and (Sha-DeArchivo $destino) -eq $entrada.Sha) { continue }
    }
    $descargar.Add($entrada)
    $plan.Bytes += $entrada.Tamano
  }
  $plan.Descargar = $descargar.ToArray()

  if ($null -ne $listaLocal) {
    $plan.Borrar = @($listaLocal.Keys | Where-Object { -not $listaRemota.ContainsKey($_) })
  }
  return $plan
}

#-------------------------------------------------------------------------------
# Descarga a una carpeta temporal; el juego no se toca hasta tenerlo todo
#-------------------------------------------------------------------------------
function Descargar-Archivos($plan) {
  [void](New-Item -ItemType Directory -Force -Path $DirTemporal)
  $pendientes = New-Object System.Collections.Generic.Queue[object]
  $hechos = 0
  $bytesHechos = [long]0
  foreach ($entrada in $plan.Descargar) {
    $temporal = Join-Path $DirTemporal $entrada.Sha
    # Lo que ya se bajó en un intento anterior no se repite
    if ((Test-Path -LiteralPath $temporal) -and (Sha-DeArchivo $temporal) -eq $entrada.Sha) {
      $hechos++; $bytesHechos += $entrada.Tamano
    } else {
      $pendientes.Enqueue(@{ Entrada = $entrada; Intento = 1 })
    }
  }
  $total = $plan.Descargar.Count

  while ($pendientes.Count -gt 0) {
    $lote = @()
    while ($lote.Count -lt $DescargasALaVez -and $pendientes.Count -gt 0) { $lote += $pendientes.Dequeue() }
    foreach ($trabajo in $lote) {
      $trabajo.Tarea = $Cliente.GetByteArrayAsync((Url-De $plan.Config $plan.Etiqueta $trabajo.Entrada.Ruta))
    }
    foreach ($trabajo in $lote) {
      $entrada = $trabajo.Entrada
      $fallo = $null
      try {
        $bytes = $trabajo.Tarea.GetAwaiter().GetResult()
        if ((Sha-DeBytes $bytes) -ne $entrada.Sha) { $fallo = 'el archivo descargado no coincide con el original' }
        else { [IO.File]::WriteAllBytes((Join-Path $DirTemporal $entrada.Sha), $bytes) }
      } catch {
        $fallo = $_.Exception.GetBaseException().Message
      }
      if ($fallo) {
        if ($trabajo.Intento -ge $Intentos) {
          throw [ErrorActualizador]::new("No se pudo descargar '$($entrada.Ruta)': $fallo")
        }
        Start-Sleep -Seconds ($trabajo.Intento * 2)
        $pendientes.Enqueue(@{ Entrada = $entrada; Intento = $trabajo.Intento + 1 })
      } else {
        $hechos++; $bytesHechos += $entrada.Tamano
      }
    }
    $porcentaje = 100
    if ($plan.Bytes -gt 0) { $porcentaje = [Math]::Floor($bytesHechos * 100 / $plan.Bytes) }
    Write-Host ("`r  Descargando... {0,3}%  ({1} de {2} archivos, {3} de {4})      " -f $porcentaje, $hechos, $total, (Texto-Tamano $bytesHechos), (Texto-Tamano $plan.Bytes)) -NoNewline
  }
  Write-Host ''
}

function Mover-ConReintentos([string]$origen, [string]$destino) {
  for ($i = 1; ; $i++) {
    try {
      [IO.File]::Copy($origen, $destino, $true)
      return
    } catch {
      if ($i -ge 20) { throw [ErrorActualizador]::new("No se pudo escribir '$destino'. Cierra el juego y vuelve a intentarlo. ($($_.Exception.GetBaseException().Message))") }
      Start-Sleep -Milliseconds 500
    }
  }
}

function Instalar-Archivos($plan) {
  $hechos = 0
  foreach ($entrada in $plan.Descargar) {
    $destino = Ruta-Local $entrada.Ruta
    [void](New-Item -ItemType Directory -Force -Path (Split-Path -Parent $destino))
    Mover-ConReintentos (Join-Path $DirTemporal $entrada.Sha) $destino
    if ((++$hechos % 200) -eq 0) { Write-Host "  Instalando... $hechos de $($plan.Descargar.Count)" }
  }
  foreach ($ruta in $plan.Borrar) {
    if ($ruta -eq $RutaVersion -or $ruta -eq $RutaLista) { continue }
    $destino = Ruta-Local $ruta
    if (Test-Path -LiteralPath $destino -PathType Leaf) {
      Remove-Item -LiteralPath $destino -Force -ErrorAction SilentlyContinue
      $carpeta = Split-Path -Parent $destino
      if ($carpeta -ne $Raiz -and -not (Get-ChildItem -LiteralPath $carpeta -Force | Select-Object -First 1)) {
        Remove-Item -LiteralPath $carpeta -Force -ErrorAction SilentlyContinue
      }
    }
  }
  # La lista y la versión se escriben al final: si algo falla antes, la
  # próxima vez se retoma desde donde se quedó
  [IO.File]::WriteAllBytes($ArchivoLista, $plan.BytesLista)
  [IO.File]::WriteAllBytes($ArchivoVersion, $plan.BytesVersion)
  Remove-Item -LiteralPath $DirTemporal -Recurse -Force -ErrorAction SilentlyContinue
}

function Abrir-Juego {
  if ($NoAbrirJuego) { return }
  $exe = Join-Path $Raiz 'Game.exe'
  if (Test-Path -LiteralPath $exe) { Start-Process -FilePath $exe -WorkingDirectory $Raiz }
}

function Pausa {
  if ($SinPausa) { return }
  Write-Host ''
  Write-Host 'Pulsa Enter para cerrar esta ventana...'
  [void][Console]::ReadLine()
}

#-------------------------------------------------------------------------------
# Comprobar
#-------------------------------------------------------------------------------
if ($Accion -eq 'comprobar') {
  try {
    $plan = Obtener-Plan $false
    if ($null -eq $plan.Remota) {
      Escribir-Estado ([ordered]@{ estado = 'sinversion'; local = $plan.Local })
    } elseif (-not $plan.HayNueva) {
      Escribir-Estado ([ordered]@{ estado = 'actualizado'; local = $plan.Local; remota = $plan.Remota })
    } else {
      $archivos = $plan.Descargar.Count
      if ($plan.RevisionCompleta) { $archivos = -1 }
      Escribir-Estado ([ordered]@{
          estado = 'disponible'; local = $plan.Local; remota = $plan.Remota; notas = $plan.Notas
          archivos = $archivos; tamano = (Texto-Tamano $plan.Bytes); desarrollo = [int](Es-CopiaDeDesarrollo)
        })
    }
  } catch {
    Escribir-Estado ([ordered]@{ estado = 'error'; mensaje = $_.Exception.GetBaseException().Message })
  }
  exit 0
}

#-------------------------------------------------------------------------------
# Actualizar / reparar
#-------------------------------------------------------------------------------
$Host.UI.RawUI.WindowTitle = 'Actualizador de Pokémon NG Chronicles'
Write-Host ''
Write-Host '  ====================================================='
Write-Host '    Actualizador de Pokémon NG Chronicles'
Write-Host '  ====================================================='
Write-Host ''
try {
  if ((Es-CopiaDeDesarrollo) -and -not $Forzar) {
    throw [ErrorActualizador]::new('Esta carpeta es la copia de desarrollo del juego (tiene un repositorio git). No se actualiza para no pisar tu trabajo; prueba el actualizador en una copia aparte.')
  }
  if ($PidJuego -gt 0) {
    Write-Host '  Esperando a que se cierre el juego...'
    try { Wait-Process -Id $PidJuego -Timeout 30 -ErrorAction Stop } catch {}
  }
  Write-Host '  Buscando la última versión...'
  $plan = Obtener-Plan ($Accion -eq 'reparar')
  if ($null -eq $plan.Remota) { throw [ErrorActualizador]::new('Todavía no hay ninguna versión publicada.') }
  if (-not $plan.HayNueva -and $Accion -ne 'reparar') {
    Write-Host "  Ya tienes la última versión ($($plan.Local))."
  } else {
    Write-Host "  Versión instalada: $($plan.Local)   Versión nueva: $($plan.Remota)"
    Write-Host "  Archivos a descargar: $($plan.Descargar.Count) ($(Texto-Tamano $plan.Bytes))"
    Write-Host ''
    Descargar-Archivos $plan
    Write-Host '  Instalando...'
    Instalar-Archivos $plan
    Write-Host ''
    Write-Host "  ¡Listo! El juego está actualizado a la versión $($plan.Remota)." -ForegroundColor Green
    Start-Sleep -Seconds 2
  }
  Abrir-Juego
  exit 0
} catch {
  Write-Host ''
  Write-Host '  No se pudo completar la actualización:' -ForegroundColor Red
  Write-Host "  $($_.Exception.GetBaseException().Message)" -ForegroundColor Red
  Write-Host ''
  Write-Host '  Tus partidas guardadas no se han tocado. Puedes volver a intentarlo desde'
  Write-Host '  "Comprobar actualizaciones" en el menú principal; se retomará donde se quedó.'
  Pausa
  Abrir-Juego
  exit 1
}

#===============================================================================
# Publicar una versión nueva de Pokémon NG Chronicles
#===============================================================================
# Se usa cuando decides que el estado actual del proyecto es la versión nueva.
# Hace doble clic en "Publicar version.bat" (o ejecuta este script) y:
#
#   1. Guarda todos los cambios pendientes en un commit "Versión X".
#   2. Genera la lista de archivos de esa versión (update\manifest.txt) y
#      anota el número de versión en version.json.
#   3. Crea la etiqueta vX y lo sube todo a GitHub.
#
# A partir de ese momento, los jugadores que pulsen "Comprobar actualizaciones"
# en el menú principal verán la versión nueva. Los cambios que subas a GitHub
# sin pasar por aquí NO les llegan hasta que publiques una versión.
#===============================================================================
param(
  [string]$Version,
  [string]$Notas,
  [switch]$SinSubir,
  [switch]$Si
)

$ErrorActionPreference = 'Stop'
$Utf8 = New-Object System.Text.UTF8Encoding($false)
$RaizRepo = $PSScriptRoot

function Fallo([string]$mensaje) { throw $mensaje }

#-------------------------------------------------------------------------------
# Localiza git (el del sistema o el que trae GitHub Desktop)
#-------------------------------------------------------------------------------
function Buscar-Git {
  $comando = Get-Command git -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
  if ($comando) { return $comando.Source }
  $candidatos = @(
    (Join-Path $env:ProgramFiles 'Git\cmd\git.exe'),
    (Join-Path $env:LOCALAPPDATA 'Programs\Git\cmd\git.exe')
  )
  $candidatos += @(Get-ChildItem (Join-Path $env:LOCALAPPDATA 'GitHubDesktop\app-*\resources\app\git\cmd\git.exe') -ErrorAction SilentlyContinue |
      Sort-Object { [version]($_.FullName -replace '.*\\app-([\d.]+)\\.*', '$1') } -Descending | ForEach-Object FullName)
  foreach ($ruta in $candidatos) { if ($ruta -and (Test-Path -LiteralPath $ruta)) { return $ruta } }
  Fallo 'No se encontró git. Instala GitHub Desktop (https://desktop.github.com) o Git para Windows.'
}

# Ejecuta git y devuelve su salida tal cual (UTF-8); falla si git da error
function Git {
  $info = New-Object System.Diagnostics.ProcessStartInfo
  $info.FileName = $script:GitExe
  $info.WorkingDirectory = $RaizRepo
  $info.UseShellExecute = $false
  $info.RedirectStandardOutput = $true
  $info.RedirectStandardError = $true
  $info.StandardOutputEncoding = $Utf8
  $info.StandardErrorEncoding = $Utf8
  $info.Arguments = (@('-c', 'core.quotepath=false') + $args | ForEach-Object {
      if ($_ -match '[\s"]') { '"' + ($_ -replace '"', '\"') + '"' } else { $_ }
    }) -join ' '
  $proceso = [System.Diagnostics.Process]::Start($info)
  $error_ = $proceso.StandardError.ReadToEndAsync()
  $salida = $proceso.StandardOutput.ReadToEnd()
  $proceso.WaitForExit()
  $script:UltimoCodigoGit = $proceso.ExitCode
  if ($proceso.ExitCode -ne 0 -and -not $script:GitTolerante) {
    Fallo "git $($args -join ' ') falló:`n$($error_.Result)$salida"
  }
  return $salida
}

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

try {
  $script:GitExe = Buscar-Git
  $script:GitTolerante = $false

  #-----------------------------------------------------------------------------
  # Carpeta del juego dentro del repositorio
  #-----------------------------------------------------------------------------
  if (Test-Path -LiteralPath (Join-Path $RaizRepo 'Game.exe')) {
    $Carpeta = ''
    $RaizJuego = $RaizRepo
  } else {
    $dir = Get-ChildItem -LiteralPath $RaizRepo -Directory | Where-Object { Test-Path -LiteralPath (Join-Path $_.FullName 'Game.exe') } | Select-Object -First 1
    if (-not $dir) { Fallo 'No se encontró la carpeta del juego (la que contiene Game.exe) junto a este script.' }
    $Carpeta = $dir.Name
    $RaizJuego = $dir.FullName
  }
  $ArchivoVersion = Join-Path $RaizJuego 'version.json'
  $ArchivoLista = Join-Path $RaizJuego 'update\manifest.txt'
  $ArchivoConfig = Join-Path $RaizJuego 'update\config.json'

  #-----------------------------------------------------------------------------
  # Repositorio de GitHub
  #-----------------------------------------------------------------------------
  $script:GitTolerante = $true
  $origen = (Git remote get-url origin).Trim()
  $script:GitTolerante = $false
  if (-not $origen) {
    Fallo ("Este proyecto todavía no está en GitHub.`n" +
      "Abre GitHub Desktop, pulsa 'Publish repository', DESMARCA 'Keep this code private' y publícalo.`n" +
      "Después vuelve a ejecutar este script.")
  }
  if ($origen -notmatch 'github\.com[:/]+([^/]+)/([^/]+?)(\.git)?/?$') { Fallo "No se reconoce la dirección del repositorio: $origen" }
  $Repo = "$($Matches[1])/$($Matches[2])"
  $Rama = (Git symbolic-ref --short HEAD).Trim()

  #-----------------------------------------------------------------------------
  # Número de versión
  #-----------------------------------------------------------------------------
  $actual = '0'
  if (Test-Path -LiteralPath $ArchivoVersion) {
    try { $actual = [string]([IO.File]::ReadAllText($ArchivoVersion, $Utf8) | ConvertFrom-Json).version } catch {}
  }
  Write-Host ''
  Write-Host "  Repositorio:      $Repo ($Rama)"
  Write-Host "  Versión actual:   $(if ($actual -eq '0') { '(ninguna publicada)' } else { $actual })"

  # Si la última versión se preparó pero no llegó a subirse, se termina eso primero
  if ($actual -ne '0' -and -not $SinSubir -and (Git tag --list "v$actual").Trim()) {
    $script:GitTolerante = $true
    $enGitHub = (Git ls-remote --tags origin "v$actual").Trim()
    $consultado = ($script:UltimoCodigoGit -eq 0)
    $script:GitTolerante = $false
    if ($consultado -and -not $enGitHub) {
      Write-Host ''
      Write-Host "  La versión $actual está preparada en tu PC pero no se subió a GitHub. Subiéndola..."
      & $script:GitExe -C $RaizRepo push origin $Rama "v$actual"
      if ($LASTEXITCODE -ne 0) { Fallo 'No se pudo subir a GitHub. Revisa tu conexión y vuelve a ejecutar este script.' }
      Write-Host "  ¡Versión $actual publicada!" -ForegroundColor Green
      exit 0
    }
  }

  if (-not $Version) {
    $sugerida = '1.0.0'
    if ($actual -ne '0') {
      $partes = @([regex]::Matches($actual, '\d+') | ForEach-Object { [long]$_.Value })
      $partes[$partes.Count - 1]++
      $sugerida = $partes -join '.'
    }
    $Version = Read-Host "  Número de la versión nueva [$sugerida]"
    if (-not $Version) { $Version = $sugerida }
    if (-not $PSBoundParameters.ContainsKey('Notas')) { $Notas = Read-Host '  Novedades de esta versión (una línea, opcional)' }
  }
  $Version = $Version.Trim().TrimStart('v', 'V')
  if ($Version -notmatch '^\d+(\.\d+){0,3}$') { Fallo "'$Version' no es un número de versión válido. Usa algo como 1.0.0 o 1.2." }
  if ((Comparar-Versiones $Version $actual) -le 0) { Fallo "La versión nueva ($Version) tiene que ser mayor que la actual ($actual)." }
  $Etiqueta = "v$Version"
  if ((Git tag --list $Etiqueta).Trim()) { Fallo "Ya existe una versión $Etiqueta publicada." }

  if (-not $Si) {
    Write-Host ''
    $respuesta = Read-Host "  Se publicará la versión $Version para todos los jugadores. ¿Continuar? (S/N)"
    if ($respuesta -notmatch '^[sSyY]') { Write-Host '  Cancelado.'; exit 0 }
  }

  #-----------------------------------------------------------------------------
  # Configuración del actualizador (de dónde descargan los jugadores)
  #-----------------------------------------------------------------------------
  [void](New-Item -ItemType Directory -Force -Path (Split-Path -Parent $ArchivoConfig))
  $config = [ordered]@{ repo = $Repo; rama = $Rama; carpeta = $Carpeta }
  if (Test-Path -LiteralPath $ArchivoConfig) {
    try {
      $anterior = [IO.File]::ReadAllText($ArchivoConfig, $Utf8) | ConvertFrom-Json
      if ($anterior.urlBase) { $config.urlBase = [string]$anterior.urlBase }
    } catch {}
  }
  $textoConfig = ($config | ConvertTo-Json) + "`n"
  if (-not (Test-Path -LiteralPath $ArchivoConfig) -or [IO.File]::ReadAllText($ArchivoConfig, $Utf8) -ne $textoConfig) {
    [IO.File]::WriteAllText($ArchivoConfig, $textoConfig, $Utf8)
  }

  #-----------------------------------------------------------------------------
  # Lista de archivos de la versión
  #-----------------------------------------------------------------------------
  Write-Host ''
  Write-Host '  Preparando los archivos...'
  [void](Git add -A)
  $prefijo = ''
  if ($Carpeta) { $prefijo = "$Carpeta/" }
  $excluidos = @("${prefijo}version.json", "${prefijo}update/manifest.txt")
  $lineas = New-Object System.Collections.Generic.List[string]
  $argumentos = @('ls-files', '-s', '-z')
  if ($Carpeta) { $argumentos += @('--', $Carpeta) }
  foreach ($registro in (Git @argumentos).Split("`0")) {
    if (-not $registro) { continue }
    # Formato: <modo> <identificador> <etapa><tab><ruta>
    $tab = $registro.IndexOf("`t")
    $ruta = $registro.Substring($tab + 1)
    if ($excluidos -contains $ruta) { continue }
    $sha = $registro.Substring(0, $tab).Split(' ')[1]
    $tamano = (Get-Item -LiteralPath (Join-Path $RaizRepo ($ruta -replace '/', '\')) -Force).Length
    $lineas.Add("$sha`t$tamano`t$($ruta.Substring($prefijo.Length))")
  }
  if ($lineas.Count -eq 0) { Fallo 'No hay archivos del juego en el repositorio.' }
  [IO.File]::WriteAllText($ArchivoLista, ($lineas -join "`n") + "`n", $Utf8)

  $datosVersion = [ordered]@{ version = $Version; fecha = (Get-Date -Format 'yyyy-MM-dd'); notas = [string]$Notas }
  [IO.File]::WriteAllText($ArchivoVersion, ($datosVersion | ConvertTo-Json) + "`n", $Utf8)

  #-----------------------------------------------------------------------------
  # Commit, etiqueta y subida
  #-----------------------------------------------------------------------------
  [void](Git add -- "${prefijo}version.json" "${prefijo}update/manifest.txt")
  [void](Git commit -m "Versión $Version")
  [void](Git tag -a $Etiqueta -m "Versión $Version")
  Write-Host "  Versión $Version preparada ($($lineas.Count) archivos)."

  if ($SinSubir) {
    Write-Host '  No se ha subido a GitHub (-SinSubir).'
  } else {
    Write-Host '  Subiendo a GitHub (puede tardar si hay muchos archivos nuevos)...'
    # Sin redirigir: así se ve el progreso y git puede pedir que inicies sesión
    & $script:GitExe -C $RaizRepo push origin $Rama $Etiqueta
    if ($LASTEXITCODE -ne 0) {
      Fallo ("La versión está preparada en tu PC pero no se pudo subir a GitHub.`n" +
        "Revisa tu conexión y vuelve a ejecutar este script: terminará la subida que quedó pendiente.")
    }
    Write-Host ''
    Write-Host "  ¡Versión $Version publicada!" -ForegroundColor Green
    Write-Host '  Los jugadores la verán en "Comprobar actualizaciones" en unos minutos.'
    Write-Host "  Descarga completa para jugadores nuevos:"
    Write-Host "  https://github.com/$Repo/archive/refs/tags/$Etiqueta.zip"
  }
  exit 0
} catch {
  Write-Host ''
  Write-Host "  ERROR: $($_.Exception.Message)" -ForegroundColor Red
  exit 1
}

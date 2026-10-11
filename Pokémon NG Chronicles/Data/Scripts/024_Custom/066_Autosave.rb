#===============================================================================
# MÓDULO: Autosave System
# Sistema de guardado automático tras curar en centros pokémon
#===============================================================================

module AutosaveConfig
  # Habilitar/deshabilitar autosave por defecto
  AUTOSAVE_ENABLED = true
  
  # Mostrar mensaje cuando se hace autosave
  SHOW_AUTOSAVE_MESSAGE = true
end

class PokemonGlobalMetadata
  attr_accessor :autosaveEnabled
  
  alias_method :initialize_old, :initialize
  
  def initialize
    initialize_old
    @autosaveEnabled = AutosaveConfig::AUTOSAVE_ENABLED
  end
end

#===============================================================================
# Función de autosave
#===============================================================================

def pbAutoSave
  return unless $PokemonGlobal
  return unless $PokemonGlobal.autosaveEnabled
  
  if AutosaveConfig::SHOW_AUTOSAVE_MESSAGE
    Kernel.pbMessage(_INTL("\\se[]Se está guardando la partida automáticamente...\\se[save]\\wtnp[20]"))
  end
  
  if pbSave
    # Autosave completado silenciosamente si no mostrar mensaje
  else
    Kernel.pbMessage(_INTL("\\se[]Error al guardar automáticamente.\\wtnp[20]"))
  end
end

#===============================================================================
# Hook para curación en centro pokémon
# Agregar esto al final del método de curación en tu evento del centro pokémon
#===============================================================================

# Método auxiliar para llamar desde eventos
def pbAutosaveAfterHealing
  pbAutoSave
end
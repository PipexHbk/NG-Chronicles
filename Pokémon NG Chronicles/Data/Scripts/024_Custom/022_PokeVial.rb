###############################################################################
# POKEVIAL - ADAPTADO POR SKYFLYER
###############################################################################

# VARIABLES QUE SE UTILIZAN (cambiar el número si prefieres usar otras)
USOSACTUALES = 46
MAXIMOUSOS = 47

ItemHandlers::UseFromBag.add(:POKEVIAL,proc{|item|
  if $game_variables[USOSACTUALES]==1 # Frase en singular
    Kernel.pbMessage(_INTL("Tienes {1} curación disponible de un máximo de {2}.", 
      $game_variables[USOSACTUALES], $game_variables[MAXIMOUSOS]))
  elsif $game_variables[USOSACTUALES]>1 # Frase en plural
    Kernel.pbMessage(_INTL("Tienes {1} curaciones disponibles de un máximo de {2}.", 
      $game_variables[USOSACTUALES], $game_variables[MAXIMOUSOS]))
  else # Si no te quedan curaciones
    Kernel.pbMessage(_INTL("El Pokévial está vacío. Recárgalo en el Centro Pokémon.", 
      $game_variables[MAXIMOUSOS]))
    next 0
  end
  if Kernel.pbConfirmMessage(_INTL("¿Curar a tu equipo con el Pokévial?"))
    # Si le dices que sí, te cura todo el equipo y elimina una curación del vial.
    for i in $Trainer.party
      i.heal
    end
    pbMEPlay("Pokemon Healing")
    Graphics.wait(30)
    Kernel.pbMessage(_INTL("¡Tu equipo ha sido curado!"))
    # Quitamos un uso del vial al curarte al equipo.
    $game_variables[USOSACTUALES] = $game_variables[USOSACTUALES]-1
  end
  next 0
})

# AGREGAR ESTE HANDLER PARA PERMITIR REGISTRAR
ItemHandlers::UseInField.add(:POKEVIAL, proc do |item|
  if $game_variables[USOSACTUALES] > 0
    if Kernel.pbConfirmMessage(_INTL("¿Curar a tu equipo con el Pokévial?"))
      for i in $Trainer.party
        i.heal
      end
      pbMEPlay("Pokemon Healing")
      Graphics.wait(30)
      Kernel.pbMessage(_INTL("¡Tu equipo ha sido curado!"))
      $game_variables[USOSACTUALES] = $game_variables[USOSACTUALES]-1
      return true
    end
  else
    Kernel.pbMessage(_INTL("El Pokévial está vacío. Recárgalo en el Centro Pokémon."))
  end
  return false
end)
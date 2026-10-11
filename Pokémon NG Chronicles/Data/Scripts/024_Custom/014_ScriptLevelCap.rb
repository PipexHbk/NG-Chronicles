###############################################################
#               LevelCap aplicado a Caramelos X               #
#                   Adaptación : Bezier                       #
#                     LevelCap : Clara                        #
###############################################################
# Esta adaptación encapsula el LevelCap de Clara en un Módulo #
# que sea cómodo de usar, llamando a la función:              #
#   nivelLimite = LevelCap.GetLimitLevel                      #
#                                                             #
# Usa ese nivel para limitar la cantidad de experiencia que   #
# recibe un Pokémon al usar caramelos de experiencia y        #
# dependiendo de las medallas obtenidas                       #
###############################################################
 
# Encapsula el código del LevelCap para facilitar su uso desde varios puntos estratégicos
# Como puede ser esta adaptación de caramelos de experiencia o el repartir experiencia
module LevelCap
  def self.GetLimitLevel
    # Level cap de Clara. Devuelve un nivel máximo dependiendo de las medallas obtenidas
    level=12
    level=17  if $game_switches[4]
    level=25  if $game_switches[5]
    level=35  if $game_switches[6]
    level=43  if $game_switches[7]
    level=50  if $game_switches[8]
    level=55  if $game_switches[9]
    level=60  if $game_switches[10]
    level=75  if $game_switches[11]
    level=85  if $game_switches[12]
    level=100 if $game_switches[241]
    return level
  end
end
 
ItemHandlers::UseOnPokemon.add(:EXPCANDYXS,proc{|item,pokemon,scene|
  if pokemon.level>=PBExperience::MAXLEVEL || (pokemon.isShadow? rescue false)
    scene.pbDisplay(_INTL("No tendrá ningún efecto."))
    next false
  else
 
    # Level cap -> Obtiene el nivel máximo que se puede alcanzar con las medallas actuales
    badgelevelcap=LevelCap.GetLimitLevel
 
    if pokemon.level>=badgelevelcap
      scene.pbDisplay(_INTL("No tendrá ningún efecto."))
      next false
    end
 
    experience=100   if isConst?(item,PBItems,:EXPCANDYXS)
    experience=800   if isConst?(item,PBItems,:EXPCANDYS)
    experience=3000  if isConst?(item,PBItems,:EXPCANDYM)
    experience=10000 if isConst?(item,PBItems,:EXPCANDYL)
    experience=30000 if isConst?(item,PBItems,:EXPCANDYXL)
    newexp=PBExperience.pbAddExperience(pokemon.exp,experience,pokemon.growthrate)
    newlevel=PBExperience.pbGetLevelFromExperience(newexp,pokemon.growthrate)
 
    # Si el nuevo nivel tras la experiencia es igual o superior al límite
    if newlevel>=badgelevelcap
      # Actualiza la experiencia y el nuevo nivel en el límite
      newexp=PBExperience.pbGetStartExperience(badgelevelcap, pokemon.growthrate)
      newlevel=badgelevelcap
      # Bloquea la experiencia si el nuevo nivel es el del Pokémon
      if newlevel==pokemon.level
        scene.pbDisplay(_INTL("No tendrá ningún efecto."))
        next false
      end
    end
  
    curlevel=pokemon.level
    scene.pbDisplay(_INTL("¡Tu Pokémon ganó Puntos de Experiencia!"))
    if newlevel==curlevel
      pokemon.exp=newexp
      pokemon.calcStats
      scene.pbRefresh
    else
      attackdiff=pokemon.attack
      defensediff=pokemon.defense
      speeddiff=pokemon.speed
      spatkdiff=pokemon.spatk
      spdefdiff=pokemon.spdef
      totalhpdiff=pokemon.totalhp
      oldlevel=pokemon.level
      pokemon.level=newlevel
      pokemon.calcStats
      scene.pbRefresh
      Kernel.pbMessage(_INTL("\\se[Pkmn level up]¡{1} subió al nivel {2}!",pokemon.name,pokemon.level))
      attackdiff=pokemon.attack-attackdiff
      defensediff=pokemon.defense-defensediff
      speeddiff=pokemon.speed-speeddiff
      spatkdiff=pokemon.spatk-spatkdiff
      spdefdiff=pokemon.spdef-spdefdiff
      totalhpdiff=pokemon.totalhp-totalhpdiff
      pbTopRightWindow(_INTL("PS Máx.<r>+{1}\r\nAtaque<r>+{2}\r\nDefensa<r>+{3}\r\nAt. Esp.<r>+{4}\r\nDef. Esp.<r>+{5}\r\nVelocidad<r>+{6}",
        totalhpdiff,attackdiff,defensediff,spatkdiff,spdefdiff,speeddiff))
      pbTopRightWindow(_INTL("PS Máx.<r>{1}\r\nAtaque<r>{2}\r\nDefensa<r>{3}\r\nAt. Esp.<r>{4}\r\nDef. Esp.<r>{5}\r\nVelocidad<r>{6}",
        pokemon.totalhp,pokemon.attack,pokemon.defense,pokemon.spatk,pokemon.spdef,pokemon.speed))
      movelist=pokemon.getMoveList
      for i in movelist
        if i[0]>oldlevel && i[0]<=pokemon.level
          pbLearnMove(pokemon,i[1],true)
        end
      end
      newspecies=pbCheckEvolution(pokemon)
      if newspecies>0
        pbFadeOutInWithMusic(99999){
          evo=PokemonEvolutionScene.new
          evo.pbStartScreen(pokemon,newspecies)
          evo.pbEvolution
          evo.pbEndScreen
        }
      end
      pokemon.exp=newexp
      scene.pbRefresh
    end
    next true
  end
})
 
ItemHandlers::UseOnPokemon.copy(:EXPCANDYXS,:EXPCANDYS,:EXPCANDYM,:EXPCANDYL,:EXPCANDYXL)
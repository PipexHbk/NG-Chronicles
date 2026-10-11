#===============================================================================
# Mirror Battle System - Sistema de Combate Espejo
# Para Pokemon Essentials BES
#===============================================================================

module MirrorBattle
  # Equipo personalizado guardado (se guarda en la partida)
  @@custom_team = nil
  
  #-----------------------------------------------------------------------------
  # Guarda el equipo actual como equipo personalizado
  #-----------------------------------------------------------------------------
  def self.saveCustomTeam
    if $Trainer.party.length == 0
      Kernel.pbMessage(_INTL("No tienes Pokémon en tu equipo."))
      return false
    end
    
    @@custom_team = []
    for pokemon in $Trainer.party
      @@custom_team.push(self.clonePokemon(pokemon))
    end
    
    Kernel.pbMessage(_INTL("Equipo personalizado guardado correctamente."))
    return true
  end
  
  #-----------------------------------------------------------------------------
  # Verifica si hay un equipo personalizado guardado
  #-----------------------------------------------------------------------------
  def self.hasCustomTeam?
    return @@custom_team && @@custom_team.length > 0
  end
  
  #-----------------------------------------------------------------------------
  # Borra el equipo personalizado
  #-----------------------------------------------------------------------------
  def self.clearCustomTeam
    @@custom_team = nil
    Kernel.pbMessage(_INTL("Equipo personalizado eliminado."))
  end
  
  #-----------------------------------------------------------------------------
  # Clona un Pokémon con todos sus datos exactos
  #-----------------------------------------------------------------------------
  def self.clonePokemon(original)
    # Crear un nuevo Pokémon idéntico
    clone = PokeBattle_Pokemon.new(original.species, original.level)
    
    # Copiar datos básicos
    clone.form = original.form
    clone.setGender(original.gender)
    clone.makeShiny if original.isShiny?
    clone.setNature(original.nature)
    clone.setAbility(original.abilityIndex)
    clone.setItem(original.item)
    clone.happiness = original.happiness
    if original.name != PBSpecies.getName(original.species)
      clone.name = original.name
    end
    clone.trainerID = original.trainerID
    clone.ot = original.ot
    if original.respond_to?(:language)
      clone.language = original.language
    end
    
    # Copiar IVs
    for i in 0...6
      clone.iv[i] = original.iv[i]
    end
    
    # Copiar EVs
    for i in 0...6
      clone.ev[i] = original.ev[i]
    end
    
    # Copiar movimientos con PP exacto
    clone.moves.clear
    for move in original.moves
      clone.moves.push(PBMove.new(move.id))
      clone.moves[clone.moves.length-1].pp = move.pp
      clone.moves[clone.moves.length-1].ppup = move.ppup
    end
    
    # Copiar HP actual y estado
    clone.hp = original.hp
    clone.status = original.status
    clone.statusCount = original.statusCount
    
    # Copiar Pokerus
    if original.respond_to?(:pokerus)
      clone.pokerus = original.pokerus
    end
    
    # Copiar Ball
    if original.respond_to?(:ballused)
      clone.ballused = original.ballused
    end
    
    # Recalcular stats
    clone.calcStats
    
    return clone
  end
  
  #-----------------------------------------------------------------------------
  # Crea el equipo espejo basado en el equipo actual del jugador
  #-----------------------------------------------------------------------------
  def self.createMirrorTeam
    mirror_team = []
    for pokemon in $Trainer.party
      mirror_team.push(self.clonePokemon(pokemon))
    end
    return mirror_team
  end
  
  #-----------------------------------------------------------------------------
  # Obtiene el nombre del entrenador espejo (mismo que el jugador)
  #-----------------------------------------------------------------------------
  def self.getMirrorTrainerName
    return $Trainer.name
  end
  
  #-----------------------------------------------------------------------------
  # Obtiene el tipo de entrenador según la variable 51
  #-----------------------------------------------------------------------------
  def self.getMirrorTrainerType
    # Variable 51: 0 = Chico, 1 = Chica
    if $game_variables[51] == 1
      return PBTrainers::POKEMONTRAINER_Mary
    else
      return PBTrainers::POKEMONTRAINER_Alex
    end
  end
  
  #-----------------------------------------------------------------------------
  # Inicia un combate espejo
  # mode: 0 = Individual, 1 = Doble, 2 = Personalizado
  #-----------------------------------------------------------------------------
  def self.startBattle(mode)
    mode = 0 if !mode
    
    # Validaciones
    if $Trainer.party.length == 0
      Kernel.pbMessage(_INTL("No tienes Pokémon para combatir."))
      return false
    end
    
    if mode == 2 && !self.hasCustomTeam?
      Kernel.pbMessage(_INTL("No has guardado ningún equipo personalizado."))
      return false
    end
    
    # Determinar el equipo rival
    if mode == 2
      opponent_team = @@custom_team
    else
      opponent_team = self.createMirrorTeam
    end
    
    # Verificar que haya suficientes Pokémon para dobles
    if mode == 1 && $Trainer.party.length < 2
      Kernel.pbMessage(_INTL("Necesitas al menos 2 Pokémon para un combate doble."))
      return false
    end
    
    # Crear el entrenador espejo
    mirror_trainer = self.createMirrorTrainer(opponent_team)
    
    # Determinar si es combate doble
    is_double = (mode == 1)
    
    # Mensaje antes del combate
    Kernel.pbMessage(_INTL("Tu reflejo aparece frente a ti..."))
    Kernel.pbMessage(_INTL("¡Es hora de enfrentarte a ti mismo!"))
    
    # Iniciar la batalla
    scene = pbNewBattleScene
    battle = PokeBattle_Battle.new(scene, $Trainer.party, opponent_team, $Trainer, mirror_trainer)
    battle.doublebattle = is_double
    battle.internalbattle = true
    battle.endspeech = "..."
    
    pbPrepareBattle(battle)
    decision = 0
    
    trainerbgm = pbGetTrainerBattleBGM(mirror_trainer)
    pbBattleAnimation(trainerbgm, (is_double ? 3 : 1), [mirror_trainer]) {
      pbSceneStandby {
        decision = battle.pbStartBattle(true)  # true = puede perder sin consecuencias
      }
      # NO llamar a pbAfterBattle para evitar dar dinero
    }
    
    # Curar completamente al equipo después del combate
    for pokemon in $Trainer.party
      pokemon.heal
    end
    
    # Mensajes post-batalla
    if decision == 1
      Kernel.pbMessage(_INTL("Has superado tu propio reflejo."))
      Kernel.pbMessage(_INTL("Realmente eres un gran entrenador."))
    elsif decision == 2
      Kernel.pbMessage(_INTL("Tu reflejo fue más fuerte..."))
      Kernel.pbMessage(_INTL("Aún tienes mucho que aprender."))
    elsif decision == 5
      Kernel.pbMessage(_INTL("Ambos cayeron al mismo tiempo."))
    end
    
    # Limpieza de memoria para Joiplay
    GC.start
    
    return decision
  end
  
  #-----------------------------------------------------------------------------
  # Crea el objeto entrenador espejo
  #-----------------------------------------------------------------------------
  def self.createMirrorTrainer(team)
    # Obtener el tipo de entrenador según la variable 51
    trainer_type = self.getMirrorTrainerType
    
    # Crear entrenador con el mismo nombre del jugador
    trainer = PokeBattle_Trainer.new(self.getMirrorTrainerName, trainer_type)
    trainer.party = team
    trainer.id = $Trainer.id
    
    return trainer
  end
  
  #-----------------------------------------------------------------------------
  # Menú principal del sistema de combate espejo
  #-----------------------------------------------------------------------------
  def self.showMenu
    loop do
      commands = []
      commands.push(_INTL("Combate Individual"))
      commands.push(_INTL("Combate Doble"))
      commands.push(_INTL("Gestionar Equipo Personalizado"))
      commands.push(_INTL("Salir"))
      
      choice = Kernel.pbMessage(
        _INTL("¿Qué tipo de combate espejo deseas?"),
        commands,
        -1
      )
      
      if choice == 0
        self.startBattle(0)
      elsif choice == 1
        self.startBattle(1)
      elsif choice == 2
        self.customTeamMenu
      elsif choice == -1 || choice == 3
        break
      end
    end
  end
  
  #-----------------------------------------------------------------------------
  # Menú de gestión del equipo personalizado
  #-----------------------------------------------------------------------------
  def self.customTeamMenu
    loop do
      commands = []
      commands.push(_INTL("Guardar Equipo Actual"))
      commands.push(_INTL("Combatir vs Equipo Guardado"))
      commands.push(_INTL("Ver Equipo Guardado"))
      commands.push(_INTL("Borrar Equipo Guardado"))
      commands.push(_INTL("Volver"))
      
      choice = Kernel.pbMessage(
        _INTL("Gestión de Equipo Personalizado"),
        commands,
        -1
      )
      
      if choice == 0
        self.saveCustomTeam
      elsif choice == 1
        if self.hasCustomTeam?
          battle_commands = []
          battle_commands.push(_INTL("Combate Individual"))
          battle_commands.push(_INTL("Combate Doble"))
          battle_commands.push(_INTL("Cancelar"))
          
          battle_choice = Kernel.pbMessage(
            _INTL("¿Qué tipo de combate?"),
            battle_commands,
            -1
          )
          
          if battle_choice == 0
            self.startBattle(2)
          elsif battle_choice == 1
            if @@custom_team.length >= 2
              self.startBattle(2)
            else
              Kernel.pbMessage(_INTL("El equipo guardado necesita al menos 2 Pokémon para combate doble."))
            end
          end
        else
          Kernel.pbMessage(_INTL("No hay equipo guardado."))
        end
      elsif choice == 2
        if self.hasCustomTeam?
          self.showCustomTeam
        else
          Kernel.pbMessage(_INTL("No hay equipo guardado."))
        end
      elsif choice == 3
        if self.hasCustomTeam?
          if Kernel.pbConfirmMessage(_INTL("¿Borrar el equipo guardado?"))
            self.clearCustomTeam
          end
        else
          Kernel.pbMessage(_INTL("No hay equipo guardado."))
        end
      elsif choice == -1 || choice == 4
        break
      end
    end
  end
  
  #-----------------------------------------------------------------------------
  # Muestra el equipo personalizado guardado
  #-----------------------------------------------------------------------------
  def self.showCustomTeam
    if !self.hasCustomTeam?
      Kernel.pbMessage(_INTL("No hay equipo guardado."))
      return
    end
    
    text = _INTL("Equipo Personalizado Guardado:\\n")
    for i in 0...@@custom_team.length
      pokemon = @@custom_team[i]
      text += _INTL("{1}. {2} Nv.{3}\\n", i+1, pokemon.name, pokemon.level)
    end
    
    Kernel.pbMessage(text)
  end
end

#===============================================================================
# Funciones globales para llamar desde eventos
#===============================================================================

# Abre el menú principal del combate espejo
def pbMirrorBattleMenu
  MirrorBattle.showMenu
end

# Inicia un combate espejo individual directamente
def pbMirrorBattleSingle
  MirrorBattle.startBattle(0)
end

# Inicia un combate espejo doble directamente
def pbMirrorBattleDouble
  MirrorBattle.startBattle(1)
end

# Guarda el equipo actual como personalizado
def pbSaveMirrorTeam
  MirrorBattle.saveCustomTeam
end

# Combate contra equipo personalizado
def pbMirrorBattleCustom
  MirrorBattle.startBattle(2)
end

puts "Mirror Battle System cargado correctamente"


## **Cómo usar el script:**
###
### **1. En un evento del mapa (para abrir el menú completo):**
###```
###◆Script: pbMirrorBattleMenu
###```
###
###Esto abrirá un menú con todas las opciones.
###
### **2. Para combates directos desde eventos:**
###
###**Combate Individual:**
###```
###◆Script: pbMirrorBattleSingle
###```
###
###**Combate Doble:**
###```
###◆Script: pbMirrorBattleDouble
###```
###
###**Guardar equipo personalizado:**
###```
###◆Script: pbSaveMirrorTeam
###```
###
###**Combatir vs equipo guardado:**
###```
###◆Script: pbMirrorBattleCustom
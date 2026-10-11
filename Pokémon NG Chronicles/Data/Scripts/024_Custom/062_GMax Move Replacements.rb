#===============================================================================
# Transformación de movimientos con Megapiedras "G"
# Por: [Tu nombre]
#===============================================================================
module GMaxMoveReplacements
  # ============================================================================
  # MAPEO DE TRANSFORMACIONES
  # Formato: ESPECIE => { MOVIMIENTO_ORIGINAL => MOVIMIENTO_TRANSFORMADO }
  # ============================================================================
  MOVE_REPLACEMENTS = {
    PBSpecies::CHARIZARD => {
      PBMoves::FIREBLAST => PBMoves::GMAXWILDFIRE  # ✅ CORRECTO
    },
    PBSpecies::VENUSAUR => {
      PBMoves::PETALDANCE => PBMoves::GMAXVINE       # Ejemplo: Danza Pétalo → Látigo G
    },
    PBSpecies::BLASTOISE => {
      PBMoves::HYDROPUMP => PBMoves::GMAXCANNONADE   # Ejemplo: Hidrobomba → Cañonazo G
    },
    PBSpecies::GENGAR => {
      PBMoves::SHADOWBALL => PBMoves::GMAXTERROR     # Ejemplo: Bola Sombra → Terror G
    }
    # AÑADE MÁS ESPECIES AQUÍ
  }

  # ============================================================================
  # MÉTODOS DEL MÓDULO (NO MODIFICAR)
  # ============================================================================
  
  # Verifica si una megapiedra es de tipo "G"
  def self.isGMaxStone?(item)
    return false if !item
    itemname = PBItems.getName(item)
    return itemname.upcase.end_with?("G") # Termina en "G"
  end

  # Obtiene las transformaciones para una especie
  def self.getReplacements(species)
    return MOVE_REPLACEMENTS[species] || {}
  end

  # Transforma los movimientos de un Pokémon (EN COMBATE)
  def self.transformMoves(battler)
    return if !battler || !battler.pokemon
    
    replacements = getReplacements(battler.species)
    return if replacements.empty?

    # Guardar movimientos originales si no se han guardado
    if !battler.pokemon.instance_variable_defined?(:@originalMoves)
      battler.pokemon.instance_variable_set(:@originalMoves, nil)
    end
    
    if !battler.pokemon.instance_variable_get(:@originalMoves)
      original_moves = []
      for i in 0...battler.pokemon.moves.length
        original_moves.push(battler.pokemon.moves[i].id)
      end
      battler.pokemon.instance_variable_set(:@originalMoves, original_moves)
      PBDebug.log("[GMax G] Movimientos originales guardados: #{original_moves.inspect}")
    end

    # Transformar movimientos
    changed = false
    for i in 0...battler.pokemon.moves.length
      current_move = battler.pokemon.moves[i].id
      new_move = replacements[current_move]
      
      if new_move
        battler.pokemon.moves[i] = PBMove.new(new_move)
        battler.moves[i] = PokeBattle_Move.pbFromPBMove(battler.battle, battler.pokemon.moves[i])
        
        battler.battle.pbDisplay(_INTL("¡{1} se transformó en {2}!",
          PBMoves.getName(current_move),
          PBMoves.getName(new_move)))
        
        PBDebug.log("[GMax G] #{PBMoves.getName(current_move)} → #{PBMoves.getName(new_move)} (slot #{i})")
        changed = true
      end
    end
    
    return changed
  end

  # Restaura los movimientos originales (FUERA DE COMBATE)
  def self.restoreMoves(pokemon)
    return if !pokemon
    return if !pokemon.instance_variable_defined?(:@originalMoves)
    
    original_moves = pokemon.instance_variable_get(:@originalMoves)
    return if !original_moves

    for i in 0...original_moves.length
      if original_moves[i] && pokemon.moves[i]
        pokemon.moves[i] = PBMove.new(original_moves[i])
        PBDebug.log("[GMax G] Restaurado: #{PBMoves.getName(original_moves[i])} en slot #{i}")
      end
    end
    
    pokemon.instance_variable_set(:@originalMoves, nil)
    PBDebug.log("[GMax G] Todos los movimientos restaurados")
  end
end
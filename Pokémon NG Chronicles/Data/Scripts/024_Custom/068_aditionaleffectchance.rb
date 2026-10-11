################################################################################
# PokeBattle_Move_Fix - Parche para pbAdditionalEffect y pbAdditionalEffectChance
# INSERTAR ARRIBA DE MAIN.RB
################################################################################

class PokeBattle_Move
  # Definir pbAdditionalEffectChance si no existe
  def pbAdditionalEffectChance(attacker, opponent)
    # Retornar la probabilidad de efecto secundario del movimiento
    if self.respond_to?(:addlEffect) && self.addlEffect
      return self.addlEffect
    end
    return 0
  end
  
  # Parchear pbAdditionalEffect para que sea completo
  alias pbAdditionalEffect_original pbAdditionalEffect
  
  def pbAdditionalEffect(attacker, opponent)
    # Llamar al método original si existe
    begin
      return pbAdditionalEffect_original(attacker, opponent)
    rescue
      # Si falla, hacer nada (sin efectos secundarios)
      return
    end
  end
end
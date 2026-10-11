module ZaibohtEvents
  def self.pbGivePokemonWithPassword(event_id)
    pbMessage("¡Felicidades por encontrarme!")
    pbMessage("No te diré quién soy, eso tú deberías saberlo.")
    pbMessage("Dime, ¿Cuál es la contraseña?")
    input = pbEnterText("Ingresa la contraseña:", 0, 13)

    if input == "Z"
      pbMessage("¡Correcto! Esto es para ti.")

      poke = PokeBattle_Pokemon.new(:RIOLU, 5, $Trainer)
      poke.setItem(:LUCARIONITE)
      poke.setAbility(2)
      poke.pbLearnMove(:DOUBLEIRONBASH)
      poke.pbLearnMove(:THUNDEROUSKICK)
      poke.pbLearnMove(:METEORMASH)
      poke.pbLearnMove(:SWORDSDANCE)
      poke.setNature(:ADAMANT)
      poke.iv = [31, 31, 31, 31, 31, 31]
      poke.ev = [0, 252, 0, 252, 4, 0]
      poke.ballused = 15
      poke.calcStats

      pbAddPokemon(poke)

      pbMessage("Mi deber ha sido cumplido, quizá nos veamos de nuevo o quizás no.")
      pbMessage("De cualquier manera, te deseo suerte.")
      pbMessage("¡Adiós!")
      pbSEPlay("Door Exit")

      return true
    else
      pbMessage("Esa no es la contraseña correcta.")
      return false
    end
  end
end

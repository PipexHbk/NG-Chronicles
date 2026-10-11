Events.onWildPokemonCreate+=proc {|sender,e|
  pokemon=e[0]
  # Condiciones
  if $game_switches[284]
    # Condición aquí
    pokemon.form = 1
    pokemon.iv[0] = 31
    pokemon.iv[1] = 31
    pokemon.iv[2] = 31
    pokemon.iv[3] = 31
    pokemon.iv[4] = 31
    pokemon.iv[5] = 31
    pokemon.pbLearnMove(:SECRETSWORD)
    pokemon.calcStats
  end
}
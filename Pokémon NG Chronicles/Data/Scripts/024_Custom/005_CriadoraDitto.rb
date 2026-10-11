Events.onWildPokemonCreate+=proc {|sender,e|
  pokemon=e[0]
  # Condiciones
  if $game_switches[106]
    # Condición aquí
    pokemon.iv[0] = 31
    pokemon.iv[1] = 31
    pokemon.iv[2] = 31
    pokemon.iv[3] = 31
    pokemon.iv[4] = 31
    pokemon.iv[5] = 31
    pkmn.ability_index = 3
    pkmn.ability = :IMPOSTER
    pokemon.shinyflag = true
    pokemon.calcStats
  end
}
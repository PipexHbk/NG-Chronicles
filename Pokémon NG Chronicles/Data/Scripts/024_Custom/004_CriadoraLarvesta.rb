Events.onWildPokemonCreate+=proc {|sender,e|
  pokemon=e[0]
  # Condiciones
  if $game_switches[105]
    # Condición aquí
    pokemon.iv[0] = 1
    pokemon.iv[1] = 1
    pokemon.iv[2] = 1
    pokemon.iv[3] = 1
    pokemon.iv[4] = 1
    pokemon.iv[5] = 1
    pkmn.ability_index = 1
    pkmn.ability = :FLAMEBODY
  end
}
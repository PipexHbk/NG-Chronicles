Events.onWildPokemonCreate+=proc {|sender,e|
  pokemon=e[0]
  # Condiciones
  if $game_switches[101]
    # Condición aquí
    pokemon.setItem(:LIFEORB)
    pokemon.iv[0] = 31
    pokemon.iv[1] = 31
    pokemon.iv[2] = 31
    pokemon.iv[3] = 31
    pokemon.iv[4] = 31
    pokemon.iv[5] = 31
    pokemon.pbDeleteAllMoves
    pokemon.pbLearnMove(:EXPLOSION)
    pokemon.calcStats
  end
}
Events.onWildPokemonCreate+=proc {|sender,e|
  pokemon=e[0]
  # Condiciones
  if $game_switches[120]
    # Condición aquí
    pokemon.setItem(:FLAMEORB)
    pokemon.natureflag = 3
    pokemon.abilityflag = 0
    pokemon.iv[0] = 31
    pokemon.iv[1] = 31
    pokemon.iv[2] = 31
    pokemon.iv[3] = 31
    pokemon.iv[4] = 31
    pokemon.iv[5] = 31
    pokemon.pbDeleteAllMoves
    pokemon.pbLearnMove(:PROTECT)
    pokemon.pbLearnMove(:FACADE)
    pokemon.pbLearnMove(:CRUNCH)
    pokemon.pbLearnMove(:EARTHQUAKE)
    pokemon.calcStats
  end
}
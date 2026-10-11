Events.onWildPokemonCreate+=proc {|sender,e|
  pokemon=e[0]
  # Condiciones
  if $game_switches[118]
    # Condición aquí
    pokemon.setItem(:SITRUSBERRY)
    pokemon.natureflag = 8
    pokemon.abilityflag = 2
    pokemon.iv[0] = 31
    pokemon.iv[1] = 31
    pokemon.iv[2] = 31
    pokemon.iv[3] = 31
    pokemon.iv[4] = 31
    pokemon.iv[5] = 31
    pokemon.pbDeleteAllMoves
    pokemon.pbLearnMove(:CRUNCH)
    pokemon.pbLearnMove(:BODYSLAM)
    pokemon.pbLearnMove(:ROCKSLIDE)
    pokemon.pbLearnMove(:RECYCLE)
    pokemon.calcStats
  end
}
Events.onWildPokemonCreate+=proc {|sender,e|
  pokemon=e[0]
  # Condiciones
  if $game_switches[122]
    # Condición aquí
    pokemon.setItem(:PUNCHINGGLOVE)
    pokemon.natureflag = 3
    pokemon.abilityflag = 0
    pokemon.form = 1
    pokemon.iv[0] = 31
    pokemon.iv[1] = 31
    pokemon.iv[2] = 31
    pokemon.iv[3] = 31
    pokemon.iv[4] = 31
    pokemon.iv[5] = 31
    pokemon.pbDeleteAllMoves
    pokemon.pbLearnMove(:POWERUPPUNCH)
    pokemon.pbLearnMove(:THUNDERPUNCH)
    pokemon.pbLearnMove(:ICEPUNCH)
    pokemon.pbLearnMove(:FIREPUNCH)
    pokemon.calcStats
  end
}
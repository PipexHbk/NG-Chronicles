Events.onWildPokemonCreate+=proc {|sender,e|
  pokemon=e[0]
  # Condiciones
  if $game_switches[218]
    # Condición aquí
    pokemon.setItem(:NEVERMELTICE)
    pokemon.natureflag = 15
    pokemon.abilityflag = 0
    pokemon.form = 1
    pokemon.iv[0] = 31
    pokemon.iv[1] = 31
    pokemon.iv[2] = 31
    pokemon.iv[3] = 31
    pokemon.iv[4] = 31
    pokemon.iv[5] = 31
    pokemon.ev[3] = 252
    pokemon.ev[4] = 252
    pokemon.pbDeleteAllMoves
    pokemon.pbLearnMove(:SPACIALREND)
    pokemon.pbLearnMove(:BLIZZARD)
    pokemon.pbLearnMove(:FREEZINGGLARE)
    pokemon.pbLearnMove(:RECOVER)
    pokemon.calcStats
  end
}
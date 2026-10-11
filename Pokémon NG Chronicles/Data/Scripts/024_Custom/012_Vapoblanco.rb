Events.onWildPokemonCreate+=proc {|sender,e|
  pokemon=e[0]
  # Condiciones
  if $game_switches[154]
    # Condición aquí
    pokemon.setItem(:BALMMUSHROOM)
    pokemon.natureflag = 15
    pokemon.abilityflag = 2
    pokemon.iv[0] = 31
    pokemon.iv[1] = 31
    pokemon.iv[2] = 31
    pokemon.iv[3] = 31
    pokemon.iv[4] = 31
    pokemon.iv[5] = 31
    pokemon.pbDeleteAllMoves
    pokemon.pbLearnMove(:SURF)
    pokemon.pbLearnMove(:ICEBEAM)
    pokemon.pbLearnMove(:SLUDGEBOMB)
    pokemon.pbLearnMove(:RECOVER)
    pokemon.calcStats
  end
}
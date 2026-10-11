Events.onWildPokemonCreate+=proc {|sender,e|
  pokemon=e[0]
  # Condiciones
  if $game_switches[116]
    # Condición aquí
    pokemon.setItem(:LOADEDDICE)
    pokemon.natureflag = 3
    pokemon.abilityflag = 2
    pokemon.iv[0] = 31
    pokemon.iv[1] = 31
    pokemon.iv[2] = 31
    pokemon.iv[3] = 31
    pokemon.iv[4] = 31
    pokemon.iv[5] = 31
    pokemon.pbDeleteAllMoves
    pokemon.pbLearnMove(:BULLETSEED)
    pokemon.pbLearnMove(:ROCKBLAST)
    pokemon.pbLearnMove(:TAILSLAP)
    pokemon.pbLearnMove(:ICICLESPEAR)
    pokemon.calcStats
  end
}
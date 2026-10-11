Events.onWildPokemonCreate+=proc {|sender,e|
  pokemon=e[0]
  # Condiciones
  if $game_switches[457]
    # Condición aquí
    pokemon.shinyflag = true
    pokemon.calcStats
  end
}
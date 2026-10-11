Events.onWildPokemonCreate+=proc {|sender,e|
  pokemon=e[0]
  # Condiciones
  if $game_switches[332]
    # Condición aquí
    pokemon.form = 3
    pokemon.calcStats
  end
}
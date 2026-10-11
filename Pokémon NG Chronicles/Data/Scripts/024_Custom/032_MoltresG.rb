Events.onWildPokemonCreate+=proc {|sender,e|
  pokemon=e[0]
  # Condiciones
  if $game_switches[315]
    # Condición aquí
    pokemon.form = 1
    pokemon.calcStats
  end
}
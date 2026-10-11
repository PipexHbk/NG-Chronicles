Events.onWildPokemonCreate+=proc {|sender,e|
  pokemon=e[0]
  # Condiciones
  if $game_switches[321]
    # Condición aquí
    pokemon.setItem(:SADAMANTORB)
    pokemon.calcStats
  end
}
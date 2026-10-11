Events.onWildPokemonCreate+=proc {|sender,e|
  pokemon=e[0]
  # Condiciones
  if $game_switches[324]
    # Condición aquí
    pokemon.setItem(:BLUEORB)
    pokemon.calcStats
  end
}
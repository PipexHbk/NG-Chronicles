Events.onWildPokemonCreate+=proc {|sender,e|
  pokemon=e[0]
  # Condiciones
  if $game_switches[322]
    # Condición aquí
    pokemon.setItem(:SGRISEOUSORB)
    pokemon.calcStats
  end
}
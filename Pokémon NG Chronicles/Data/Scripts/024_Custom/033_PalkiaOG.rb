Events.onWildPokemonCreate+=proc {|sender,e|
  pokemon=e[0]
  # Condiciones
  if $game_switches[320]
    # Condición aquí
    pokemon.setItem(:SLUSTROUSORB)
    pokemon.calcStats
  end
}
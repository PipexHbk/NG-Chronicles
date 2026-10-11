Events.onWildPokemonCreate+=proc {|sender,e|
  pokemon=e[0]
  # Condiciones
  if $game_switches[323]
    # Condición aquí
    pokemon.setItem(:REDORB)
    pokemon.calcStats
  end
}
Events.onWildPokemonCreate+=proc {|sender,e|
  pokemon=e[0]
  # Condiciones
  if $game_switches[339]
    # Condición aquí
    pokemon.setItem(:RUSTEDSHIELD)
    pokemon.pbLearnMove(:IRONHEAD)
    pokemon.calcStats
  end
}
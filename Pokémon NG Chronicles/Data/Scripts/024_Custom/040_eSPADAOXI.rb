Events.onWildPokemonCreate+=proc {|sender,e|
  pokemon=e[0]
  # Condiciones
  if $game_switches[338]
    # Condición aquí
    pokemon.setItem(:RUSTEDSWORD)
    pokemon.pbLearnMove(:IRONHEAD)
    pokemon.calcStats
  end
}
def pbSortPocket(pocket_index, mode = :alphabetical)
  pocket = $PokemonBag.pockets[pocket_index]
  return if !pocket || pocket.length <= 1
  case mode
  when :alphabetical
    # sort_by devuelve un nuevo array; usamos replace para mantener la misma referencia
    pocket.replace(pocket.sort_by { |item| PBItems.getName(item[0]) })
    pbMessage(_INTL("Los objetos se han ordenado alfabéticamente."))
  when :quantity
    # orden descendente por cantidad
    pocket.replace(pocket.sort_by { |item| -item[1] })
    pbMessage(_INTL("Los objetos se han ordenado por cantidad."))
  end
end

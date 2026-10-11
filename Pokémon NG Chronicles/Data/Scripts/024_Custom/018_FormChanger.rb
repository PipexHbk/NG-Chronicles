module FormChanger
  # ===== ESPECIES PERMITIDAS =====
  ALLOWED_SPECIES = [
    # Formas Regionales Kanto/Alola/Galar/Hisui
    PBSpecies::VULPIX, PBSpecies::NINETALES, PBSpecies::DIGLETT, PBSpecies::DUGTRIO,
    PBSpecies::MEOWTH, PBSpecies::PERSIAN, PBSpecies::GEODUDE, PBSpecies::GRAVELER,
    PBSpecies::GOLEM, PBSpecies::PONYTA, PBSpecies::RAPIDASH, PBSpecies::SLOWPOKE,
    PBSpecies::SLOWBRO, PBSpecies::SLOWKING, PBSpecies::WEEZING, PBSpecies::EXEGGUTOR,
    PBSpecies::MAROWAK, PBSpecies::RAICHU, PBSpecies::SANDSLASH, PBSpecies::MUK,
    PBSpecies::GRIMER, PBSpecies::VOLTORB, PBSpecies::ELECTRODE, PBSpecies::RATTATA,
    PBSpecies::RATICATE, PBSpecies::FARFETCHD, PBSpecies::MRMIME, PBSpecies::CORSOLA, 
    PBSpecies::ZIGZAGOON, PBSpecies::LINOONE, PBSpecies::YAMASK, PBSpecies::DECIDUEYE,
    PBSpecies::STUNFISK, PBSpecies::GROWLITHE, PBSpecies::ARCANINE, PBSpecies::QWILFISH,
    PBSpecies::SNEASEL, PBSpecies::TYPHLOSION, PBSpecies::SAMUROTT, PBSpecies::LILLIGANT,
    PBSpecies::ZORUA, PBSpecies::ZOROARK, PBSpecies::BRAVIARY, PBSpecies::SLIGGOO,
    PBSpecies::GOODRA, PBSpecies::AVALUGG, PBSpecies::MAGEARNA,
    
    # Tauros (Paldean)
    PBSpecies::TAUROS,
    
    # Wooper
    PBSpecies::WOOPER,
    
    # Otras formas NO cosméticas
    PBSpecies::BURMY,        # Formas Capa
    PBSpecies::WORMADAM,     # Formas Capa
    PBSpecies::SHELLOS,      # Este/Oeste
    PBSpecies::GASTRODON,    # Este/Oeste
    PBSpecies::ROTOM,        # Formas de Electrodomésticos
    PBSpecies::BASCULIN,     # Rayas
    PBSpecies::DEERLING,     # Estaciones
    PBSpecies::SAWSBUCK,     # Estaciones
    PBSpecies::FLABEBE,      # Colores de flor
    PBSpecies::FLOETTE,      # Colores de flor (+ Eterna)
    PBSpecies::FLORGES,      # Colores de flor
    PBSpecies::PUMPKABOO,    # Tamaños
    PBSpecies::GOURGEIST,    # Tamaños
    PBSpecies::LYCANROC,     # Día/Noche/Crepúsculo
    PBSpecies::MINIOR,       # Colores de núcleo
    PBSpecies::TOXTRICITY,   # Amped/Low Key
    PBSpecies::SQUAWKABILLY, # Colores de plumaje
    PBSpecies::TATSUGIRI,    # Curly/Droopy/Stretchy
  ]

  # ===== FORMAS ÚNICAS (NO CAMBIABLES) =====
  UNIQUE_FORMS = [
    [PBSpecies::FLOETTE, 5],      # Floette Flor Eterna
    [PBSpecies::FLOETTE, 6],      # Mega Floette (solo desde forma 5)
    [PBSpecies::GRENINJA, 1],     # Ash-Greninja (si existe en tu juego)
    [PBSpecies::NECROZMA, 3],     # Ultra Necrozma (solo desde formas fusionadas)
    [PBSpecies::ZYGARDE, 3],      # Mega Zygarde (solo desde forma completa)
    [PBSpecies::TERAPAGOS, 2],    # Forma Estelar (solo con Teracristalización)
  ]
  
  # ===== FORMAS MEGA (AUTO-DETECTADAS) =====
  MEGA_SPECIES = [
    PBSpecies::VENUSAUR, PBSpecies::CHARIZARD, PBSpecies::BLASTOISE,
    PBSpecies::ALAKAZAM, PBSpecies::GENGAR, PBSpecies::KANGASKHAN,
    PBSpecies::PINSIR, PBSpecies::GYARADOS, PBSpecies::AERODACTYL,
    PBSpecies::MEWTWO, PBSpecies::AMPHAROS, PBSpecies::SCIZOR,
    PBSpecies::HERACROSS, PBSpecies::HOUNDOOM, PBSpecies::TYRANITAR,
    PBSpecies::BLAZIKEN, PBSpecies::GARDEVOIR, PBSpecies::MAWILE,
    PBSpecies::AGGRON, PBSpecies::MEDICHAM, PBSpecies::MANECTRIC,
    PBSpecies::BANETTE, PBSpecies::ABSOL, PBSpecies::GARCHOMP,
    PBSpecies::LUCARIO, PBSpecies::ABOMASNOW, PBSpecies::BEEDRILL,
    PBSpecies::PIDGEOT, PBSpecies::STEELIX, PBSpecies::SCEPTILE,
    PBSpecies::SWAMPERT, PBSpecies::SABLEYE, PBSpecies::SHARPEDO,
    PBSpecies::CAMERUPT, PBSpecies::ALTARIA, PBSpecies::GLALIE,
    PBSpecies::SALAMENCE, PBSpecies::METAGROSS, PBSpecies::LATIAS,
    PBSpecies::LATIOS, PBSpecies::RAYQUAZA, PBSpecies::LOPUNNY,
    PBSpecies::GALLADE, PBSpecies::AUDINO, PBSpecies::DIANCIE,
    PBSpecies::FLYGON, PBSpecies::VILEPLUME, PBSpecies::BUTTERFREE,
    PBSpecies::PIKACHU, PBSpecies::KINGLER, PBSpecies::LAPRAS,
    PBSpecies::EEVEE, PBSpecies::GARBODOR, PBSpecies::MELMETAL,
    PBSpecies::RILLABOOM, PBSpecies::CINDERACE, PBSpecies::INTELEON,
    PBSpecies::CORVIKNIGHT, PBSpecies::ORBEETLE, PBSpecies::MACHAMP,
    PBSpecies::SNORLAX, PBSpecies::YANMEGA, PBSpecies::STARMIE,
    PBSpecies::MEGANIUM, PBSpecies::MEW, PBSpecies::DRAGONITE,
    PBSpecies::TORTERRA, PBSpecies::STARAPTOR, PBSpecies::LUXRAY,
    PBSpecies::MELOETTA, PBSpecies::SKARMORY, PBSpecies::RAMPARDOS,
    PBSpecies::HAXORUS, PBSpecies::SERPERIOR, PBSpecies::MIENSHAO,
    PBSpecies::VOLCARONA, PBSpecies::EXCADRILL, PBSpecies::MILOTIC,
    PBSpecies::FLORGES, PBSpecies::MEOWTH, PBSpecies::DREDNAW,
    PBSpecies::COALOSSAL, PBSpecies::FLAPPLE, PBSpecies::APPLETUN,
    PBSpecies::SANDACONDA, PBSpecies::HATTERENE, PBSpecies::TOXTRICITY,
    PBSpecies::CENTISKORCH, PBSpecies::COPPERAJAH, PBSpecies::DURALUDON,
    PBSpecies::GRIMMSNARL, PBSpecies::ALCREMIE, PBSpecies::URSHIFU,
    PBSpecies::URSHIFUAWA, PBSpecies::SHIFTRY, PBSpecies::ROSERADE,
    PBSpecies::GRENINJA, PBSpecies::DELPHOX, PBSpecies::CHESNAUGHT,
    PBSpecies::HAWLUCHA, PBSpecies::VICTREEBEL, PBSpecies::MALAMAR,
    PBSpecies::ETERNATUS, PBSpecies::DRAMPA, PBSpecies::CLEFABLE,
    PBSpecies::ZYGARDE, PBSpecies::RAICHU, PBSpecies::FERALIGATR,
    PBSpecies::FROSLASS, PBSpecies::EMBOAR, PBSpecies::SCOLIPEDE,
    PBSpecies::SCRAFTY, PBSpecies::EELEKTROSS, PBSpecies::CHANDELURE,
    PBSpecies::PYROAR, PBSpecies::FLOETTE, PBSpecies::BARBARACLE,
    PBSpecies::DRAGALGE, PBSpecies::FALINKS, PBSpecies::BAXCALIBUR,
    PBSpecies::CHIMECHO, PBSpecies::MAGEARNA, PBSpecies::TATSUGIRI,
    PBSpecies::GOLISOPOD, PBSpecies::HEATRAN, PBSpecies::DARKRAI,
    PBSpecies::GOLURK, PBSpecies::MEOWSTIC, PBSpecies::CRABOMINABLE,
    PBSpecies::ZERAORA, PBSpecies::SCOVILLAIN, PBSpecies::GLIMMORA,
    PBSpecies::JUMPLUFF
  ]

  # ===== MAPEO DE FORMAS MEGA =====
  MEGA_FORMS_MAP = {
    PBSpecies::VENUSAUR => [1, 2],
    PBSpecies::CHARIZARD => [1, 2, 3],
    PBSpecies::BLASTOISE => [1, 2],
    PBSpecies::GENGAR => [1, 2],
    PBSpecies::ABSOL => [1, 2],
    PBSpecies::GARCHOMP => [1, 2],
    PBSpecies::LUCARIO => [1, 2],
    PBSpecies::MEWTWO => [1, 2],
    PBSpecies::MELOETTA => [2],
    PBSpecies::FLORGES => [5],
    PBSpecies::MEOWTH => [4],
    PBSpecies::ALCREMIE => [63],
    PBSpecies::URSHIFU => [3],
    PBSpecies::URSHIFUAWA => [2],
    PBSpecies::GRENINJA => [2],
    PBSpecies::ZYGARDE => [3],
    PBSpecies::RAICHU => [2, 3],
    PBSpecies::FLOETTE => [6],
    PBSpecies::MAGEARNA => [2, 3],
    PBSpecies::TATSUGIRI => [3, 4, 5],
    PBSpecies::TOXTRICITY => [2]
  }

  # ===== CONFIGURACIÓN MANUAL DE FORMAS =====
  MANUAL_FORMS = {
    # Formas Regionales
    PBSpecies::VULPIX => [0, 1],
    PBSpecies::NINETALES => [0, 1],
    PBSpecies::DIGLETT => [0, 1],
    PBSpecies::DUGTRIO => [0, 1],
    PBSpecies::MEOWTH => [0, 1, 2],
    PBSpecies::PERSIAN => [0, 1],
    PBSpecies::GEODUDE => [0, 1],
    PBSpecies::GRAVELER => [0, 1],
    PBSpecies::GOLEM => [0, 1],
    PBSpecies::PONYTA => [0, 1],
    PBSpecies::RAPIDASH => [0, 1],
    PBSpecies::SLOWPOKE => [0, 1],
    PBSpecies::SLOWBRO => [0, 1],
    PBSpecies::SLOWKING => [0, 1],
    PBSpecies::GRIMER => [0, 1],
    PBSpecies::MUK => [0, 1],
    PBSpecies::WEEZING => [0, 1],
    PBSpecies::EXEGGUTOR => [0, 1],
    PBSpecies::MAROWAK => [0, 1],
    PBSpecies::RAICHU => [0, 1],
    PBSpecies::SANDSLASH => [0, 1],
    PBSpecies::SANDSHREW => [0, 1],
    PBSpecies::VOLTORB => [0, 1],
    PBSpecies::ELECTRODE => [0, 1],
    PBSpecies::RATTATA => [0, 1],
    PBSpecies::RATICATE => [0, 1],
    PBSpecies::FARFETCHD => [0, 1],
    PBSpecies::MRMIME => [0, 1],
    PBSpecies::ARTICUNO => [0, 1],
    PBSpecies::ZAPDOS => [0, 1],
    PBSpecies::MOLTRES => [0, 1],
    PBSpecies::CORSOLA => [0, 1],
    PBSpecies::ZIGZAGOON => [0, 1],
    PBSpecies::LINOONE => [0, 1],
    PBSpecies::DARUMAKA => [0, 1],
    PBSpecies::DARMANITAN => [0, 1],
    PBSpecies::YAMASK => [0, 1],
    PBSpecies::STUNFISK => [0, 1],
    PBSpecies::GROWLITHE => [0, 1],
    PBSpecies::ARCANINE => [0, 1],
    PBSpecies::QWILFISH => [0, 1],
    PBSpecies::SNEASEL => [0, 1],
    PBSpecies::TYPHLOSION => [0, 1],
    PBSpecies::SAMUROTT => [0, 1],
    PBSpecies::LILLIGANT => [0, 1],
    PBSpecies::ZORUA => [0, 1],
    PBSpecies::ZOROARK => [0, 1],
    PBSpecies::BRAVIARY => [0, 1],
    PBSpecies::SLIGGOO => [0, 1],
    PBSpecies::GOODRA => [0, 1],
    PBSpecies::AVALUGG => [0, 1],
    PBSpecies::DECIDUEYE => [0, 1],
    PBSpecies::TAUROS => [0, 1, 2, 3],
    PBSpecies::WOOPER => [0, 1],
    PBSpecies::MAGEARNA => [0, 1],
    
    # Deoxys
    PBSpecies::DEOXYS => [0, 1, 2, 3],
    
    # Burmy/Wormadam
    PBSpecies::BURMY => [0, 1, 2],
    PBSpecies::WORMADAM => [0, 1, 2],
    
    # Shellos/Gastrodon
    PBSpecies::SHELLOS => [0, 1],
    PBSpecies::GASTRODON => [0, 1],
    
    # Rotom
    PBSpecies::ROTOM => [0, 1, 2, 3, 4, 5],
    
    # Dialga/Palkia/Giratina (Formas Origen)
    PBSpecies::DIALGA => [0, 1],
    PBSpecies::PALKIA => [0, 1],
    PBSpecies::GIRATINA => [0, 1],
    
    # Shaymin
    PBSpecies::SHAYMIN => [0, 1],
    
    # Basculin
    PBSpecies::BASCULIN => [0, 1, 2],
    
    # Deerling/Sawsbuck
    PBSpecies::DEERLING => [0, 1, 2, 3],
    PBSpecies::SAWSBUCK => [0, 1, 2, 3],
    
    # Genies (Tornadus/Thundurus/Landorus/Enamorus)
    PBSpecies::TORNADUS => [0, 1],
    PBSpecies::THUNDURUS => [0, 1],
    PBSpecies::LANDORUS => [0, 1],
    PBSpecies::ENAMORUS => [0, 1],
    
    # Kyurem
    PBSpecies::KYUREM => [0, 1, 2],
    
    # Keldeo
    PBSpecies::KELDEO => [0, 1],
    
    # Meloetta (solo forma 1, forma 2 es Mega)
    PBSpecies::MELOETTA => [0, 1],
    
    # Genesect
    PBSpecies::GENESECT => [0, 1, 2, 3, 4],
    
    # Flabébé/Floette/Florges (colores 0-4, excluir forma 5 de Floette)
    PBSpecies::FLABEBE => [0, 1, 2, 3, 4],
    PBSpecies::FLOETTE => [0, 1, 2, 3, 4],
    PBSpecies::FLORGES => [0, 1, 2, 3, 4],
    
    # Meowstic/Indeedee (macho/hembra)
    PBSpecies::ESPURR => [0, 1],
    PBSpecies::MEOWSTIC => [0, 1],
    PBSpecies::INDEEDEE => [0, 1],
    
    # Pumpkaboo/Gourgeist (tamaños)
    PBSpecies::PUMPKABOO => [0, 1, 2, 3],
    PBSpecies::GOURGEIST => [0, 1, 2, 3],
    
    # Zygarde (10%/50%, excluir Completo y Mega)
    PBSpecies::ZYGARDE => [0, 1],
    
    # Hoopa
    PBSpecies::HOOPA => [0, 1],
    
    # Oricorio
    PBSpecies::ORICORIO => [0, 1, 2, 3],
    
    # Lycanroc/Rockruff
    PBSpecies::ROCKRUFF => [0, 1, 2],
    PBSpecies::LYCANROC => [0, 1, 2],
    
    # Minior (colores de núcleo)
    PBSpecies::MINIOR => [1, 2, 3, 4, 5, 6, 7],
    
    # Necrozma (Dusk/Dawn, excluir Ultra)
    PBSpecies::NECROZMA => [0, 1, 2],
    
    # Toxel/Toxtricity
    PBSpecies::TOXEL => [0, 1],
    PBSpecies::TOXTRICITY => [0, 1],
    
    # Zacian/Zamazenta
    PBSpecies::ZACIAN => [0, 1],
    PBSpecies::ZAMAZENTA => [0, 1],
    
    # Calyrex
    PBSpecies::CALYREX => [0, 1, 2],
    
    # Oinkologne
    PBSpecies::OINKOLOGNE => [0, 1],
    
    # Squawkabilly
    PBSpecies::SQUAWKABILLY => [0, 1, 2, 3],
    
    # Tatsugiri (formas base, excluir Megas)
    PBSpecies::TATSUGIRI => [0, 1, 2],
    
    # Ogerpon (máscaras)
    PBSpecies::OGERPON => [0, 1, 2, 3],
    
    # Terapagos (forma Normal/Teracristalizada, excluir Estelar)
    PBSpecies::TERAPAGOS => [0, 1],
    
    # Darmanitan Galar
    PBSpecies::DARMANITANG => [0, 1],
    
    # Missingno
    PBSpecies::MISSINGNO => [0, 1]
  }

  # ===== MÉTODOS =====

  def self.is_mega_form?(species, form)
    return false if form == 0
    
    if MEGA_FORMS_MAP.key?(species)
      return MEGA_FORMS_MAP[species].include?(form)
    end
    
    return true if MEGA_SPECIES.include?(species) && form == 1
    
    return false
  end

  def self.is_unique_form?(species, form)
    return UNIQUE_FORMS.include?([species, form])
  end

  def self.can_change_form?(poke)
    return ALLOWED_SPECIES.include?(poke.species)
  end

  def self.allowed_species_names(conector = 'y')
    names = ALLOWED_SPECIES.map { |species| PBSpecies.getName(species) }
    last = names.pop
    return names.join(', ') + " #{conector} #{last}"
  end

  def self.get_manual_forms(species)
    return MANUAL_FORMS[species] if MANUAL_FORMS.key?(species)
    return nil
  end

  def self.get_available_forms(pokemon)
    available = []
    
    manual_forms = get_manual_forms(pokemon.species)
    if manual_forms
      manual_forms.each do |form|
        next if form == pokemon.form
        next if is_mega_form?(pokemon.species, form)
        next if is_unique_form?(pokemon.species, form)
        available.push(form)
      end
      return available
    end
    
    Kernel.pbMessage("Error: #{PBSpecies.getName(pokemon.species)} no está configurado en MANUAL_FORMS.")
    return []
  end

  def self.get_form_name(species, form)
    if form == 0
      return "Forma Normal"
    end
    
    begin
      formname = pbGetMessage(MessageTypes::FormNames, species * 100 + form)
      return formname if formname && !formname.empty?
    rescue
    end
    
    return "Forma #{form}"
  end

  def self.choose_form_menu(pokemon)
    available_forms = get_available_forms(pokemon)
    
    if available_forms.empty?
      Kernel.pbMessage("Este #{PBSpecies.getName(pokemon.species)} no tiene formas alternativas disponibles.")
      return -1
    end
    
    commands = []
    available_forms.each do |form|
      commands.push(get_form_name(pokemon.species, form))
    end
    commands.push("Cancelar")
    
    cmdwindow = pbListWindow(commands, 320)
    cmdwindow.z = 99999
    cmdwindow.x = Graphics.width - cmdwindow.width
    cmdwindow.y = 0
    
    box_width = 96
    box_height = 96
    
    boxsprite = Sprite.new(nil)
    boxsprite.z = 99998
    boxsprite.bitmap = Bitmap.new(box_width, box_height)
    boxsprite.x = cmdwindow.x - box_width - 4
    boxsprite.y = cmdwindow.y + 8
    
    boxsprite.bitmap.fill_rect(4, 4, box_width - 4, box_height - 4, Color.new(0, 0, 0, 100))
    
    for i in 0...box_height
      alpha = 230 - (i * 30 / box_height)
      boxsprite.bitmap.fill_rect(0, i, box_width - 4, 1, Color.new(32, 40, 56, alpha))
    end
    
    boxsprite.bitmap.fill_rect(0, 0, box_width - 4, 3, Color.new(136, 168, 208, 200))
    boxsprite.bitmap.fill_rect(0, 0, 3, box_height - 4, Color.new(136, 168, 208, 200))
    boxsprite.bitmap.fill_rect(0, box_height - 7, box_width - 4, 3, Color.new(64, 80, 104, 200))
    boxsprite.bitmap.fill_rect(box_width - 7, 0, 3, box_height - 4, Color.new(64, 80, 104, 200))
    
    iconsprite = PokemonIconSprite.new(pokemon, nil)
    iconsprite.z = 99999
    iconsprite.x = boxsprite.x + ((box_width - 4) / 2) - 32
    iconsprite.y = boxsprite.y + ((box_height - 4) / 2) - 32
    
    update_preview = lambda { |index|
      iconsprite.dispose if iconsprite
      
      if index >= 0 && index < available_forms.length
        form = available_forms[index]
        temp_pkmn = PokeBattle_Pokemon.new(pokemon.species, pokemon.level)
        temp_pkmn.form = form
        temp_pkmn.makeShiny if pokemon.isShiny?
        
        iconsprite = PokemonIconSprite.new(temp_pkmn, nil)
        iconsprite.z = 99999
        iconsprite.x = boxsprite.x + ((box_width - 4) / 2) - 32
        iconsprite.y = boxsprite.y + ((box_height - 4) / 2) - 32
      else
        iconsprite = PokemonIconSprite.new(pokemon, nil)
        iconsprite.z = 99999
        iconsprite.x = boxsprite.x + ((box_width - 4) / 2) - 32
        iconsprite.y = boxsprite.y + ((box_height - 4) / 2) - 32
      end
    }
    
    update_preview.call(cmdwindow.index)
    
    choice = -1
    oldindex = cmdwindow.index
    
    loop do
      Graphics.update
      Input.update
      cmdwindow.update
      iconsprite.update if iconsprite
      
      if cmdwindow.index != oldindex
        update_preview.call(cmdwindow.index)
        oldindex = cmdwindow.index
      end
      
      if Input.trigger?(Input::B)
        choice = -1
        break
      end
      
      if Input.trigger?(Input::C) || Input.trigger?(Input::A)
        choice = cmdwindow.index
        break
      end
    end
    
    iconsprite.dispose if iconsprite
    boxsprite.bitmap.dispose
    boxsprite.dispose
    cmdwindow.dispose
    
    return -1 if choice == -1 || choice >= available_forms.length
    return available_forms[choice]
  end

  def self.change_to_form(form)
    pbChoosePokemon(1, 2, proc { |poke| 
      !poke.isEgg? && 
      !poke.isShadow? && 
      ALLOWED_SPECIES.include?(poke.species) && 
      poke.form != form &&
      !is_mega_form?(poke.species, form) &&
      !is_unique_form?(poke.species, form)
})
return false unless $game_variables[1] != -1

pokemon = $Trainer.party[pbGet(1)]
species_name = PBSpecies.getName(pokemon.species)
form_name = get_form_name(pokemon.species, form)

if pokemon.form == form
  Kernel.pbMessage("¡Tu #{species_name} ya está en su #{form_name}!")
  return false
end

Kernel.pbMessage("¡Bien, pues transformaré a tu #{species_name} en su #{form_name}!")
pokemon.form = form
pokemon.calcStats
true
end
def self.change_form_menu
pbChoosePokemon(1, 2, proc { |poke|
!poke.isEgg? &&
!poke.isShadow? &&
ALLOWED_SPECIES.include?(poke.species) &&
get_available_forms(poke).length > 0
})
return false unless $game_variables[1] != -1

pokemon = $Trainer.party[pbGet(1)]
species_name = PBSpecies.getName(pokemon.species)

chosen_form = choose_form_menu(pokemon)
return false if chosen_form == -1

form_name = get_form_name(pokemon.species, chosen_form)
current_form_name = get_form_name(pokemon.species, pokemon.form)

if Kernel.pbConfirmMessage("¿Cambiar de #{current_form_name} a #{form_name}?")
  pokemon.form = chosen_form
  pokemon.calcStats
  Kernel.pbMessage("¡#{species_name} cambió a su #{form_name}!")
  return true
end

return false
end
def self.force_change_form(pokemon_index, new_form)
return false if pokemon_index < 0 || pokemon_index >= $Trainer.party.length
pokemon = $Trainer.party[pokemon_index]
return false if !pokemon || pokemon.isEgg?

old_form = pokemon.form
pokemon.form = new_form
pokemon.calcStats

species_name = PBSpecies.getName(pokemon.species)
form_name = get_form_name(pokemon.species, new_form)

Kernel.pbMessage("¡#{species_name} cambió a su #{form_name}!")
PBDebug.log("Force form change: #{species_name} from form #{old_form} to #{new_form}")

return true
end
end
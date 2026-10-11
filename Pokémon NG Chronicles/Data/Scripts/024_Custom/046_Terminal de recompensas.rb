module ZaibohtEvents
  # Lista maestra de contraseñas y su descripción
  PASSWORD_REWARDS = {
    "PLUSLURIO"   => "Riolu especial - PLUSLURIO",
    "IKUZEE"      => "Froakie especial - IKUZEE",
    "BIGMAMA"     => "Chansey especial - BIGMAMA",
    "STEELSTALL"  => "Ferrothorn especial - STEELSTALL",
    "DIEHARD"     => "Shedinja especial - DIEHARD",
    "MEGAMONKI"   => "Slaking especial - MEGAMONKI",
    "DEATHSTARE"  => "Xatu especial - DEATHSTARE",
    "VGCLEGEND"   => "Pachirisu especial - VGCLEGEND",
    "DRACUTREE"   => "Trevenant especial - DRACUTREE",
    "STALLYUKU"   => "Pyukumuku especial - STALLYUKU",
    "BOLTTHEDOG"  => "Boltund especial - BOLTTHEDOG",
    "TERRORGHOST" => "Annihilape especial - TERRORGHOST",
    "SUMOYAMA"    => "Ferropalmas especial - SUMOYAMA",
    "GALLADEVOIR" => "Ferropaladín especial - GALLADEVOIR",
    "GODSLAYER"   => "Pikachu especial - GODSLAYER",
    "NOCTOBLUE"   => "Umbreon especial - NOCTOBLUE",
    "FLASHKUDA"   => "Barraskewda especial - FLASHKUDA",
    "NANOMACHINES" => "Shuckle especial - NANOMACHINES",
    "KANSEIDORIFTO" => "Ninjask especial - KANSEIDORIFTO",
    "NOINFORMATION" => "MissingNo - NOINFORMATION"
  }

  # Asegura que la variable 102 sea un array
  def self.ensure_store!
    $game_variables[102] = [] unless $game_variables[102].is_a?(Array)
  end

  # Opción 1 del evento: ingresar/canjear contraseña
  def self.pbRedeemPassword(event_id)
    ensure_store!

    pbMessage("Dime, ¿cuál es tu contraseña?")
    input = pbEnterText("Ingresa la contraseña:", 0, 13)
    return false if !input || input.empty?
    input = input.upcase

    # Validación de existencia
    unless PASSWORD_REWARDS.key?(input)
      pbMessage("Buen intento, pero no conozco esa contraseña.")
      return false
    end

    # Validación de ya canjeada
    if $game_variables[102].include?(input)
      pbMessage("Esa contraseña ya fue usada, no puedo dártela de nuevo.")
      return false
    end

    # Variables comunes para la entrega
    species = nil
    level = 5
    moves = []
    item = nil
    nature = nil
    ball = 1
    ability = nil          # índice de habilidad (0/1/2) si aplica
    custom_ability = nil   # símbolo si usas habilidades personalizadas por ID
    ev_override = nil      # [HP, Atk, Def, SpA, SpD, Spe] o nil
    shiny = false
    
    case input
    when "PLUSLURIO"
      species = :RIOLU
      moves = [:DOUBLEIRONBASH, :THUNDEROUSKICK, :BULLETPUNCH, :VICTORYDANCE]
      item = :LUCARIONITE
      ability = 2
      nature = :ADAMANT
      ball = 15
    when "IKUZEE"
      species = :FROAKIE
      moves = [:STEAMERUPTION, :FIERYWRATH, :LUSTERPURGE, :SEEDFLARE]
      item = :KINGSROCK
      ability = 1
      nature = :MODEST
      ball = 15
    when "BIGMAMA"
      species = :CHANSEYIMPOSTER
      moves = [:SHOREUP, :WHIRLWIND, :UTURN, :METALBURST]
      item = :EVIOLITE
      nature = :RELAXED
      ev_override = [252, 0, 0, 0, 0, 0]
      ball = 15
    when "STEELSTALL"
      species = :FERROPLUS
      moves = [:SHOREUP, :ANCHORSHOT, :SPECTRALTHIEF, :CONGELAO]
      item = :LEFTOVERS
      nature = :SASSY
      ev_override = [4, 0, 252, 0, 0, 252]
      ball = 15
    when "DIEHARD"
      species = :SHEDINJAPLUS
      moves = [:ENDEAVOR, :EXTREMESPEED, :UTURN, :FORESIGHT]
      item = :PROTECTIVEPADS
      nature = :ADAMANT
      ev_override = [0, 252, 0, 252, 0, 0]
      ball = 15
    when "MEGAMONKI"
      species = :SLAKINGPLUS
      moves = [:SWORDSDANCE, :HYPERDRILL, :FUERZACORPOREA, :MAGICALTORQUE]
      item = :LIFEORBPLUS
      nature = :ADAMANT
      ev_override = [0, 252, 0, 252, 0, 0]
      ball = 15
    when "DEATHSTARE"
      species = :XATUPLUS
      moves = [:OBLIVIONWING, :PHOTONGEYSER, :BUGBUZZ, :SEARINGSHOT]
      item = :ASSAULTVEST
      nature = :MODEST
      ev_override = [0, 0, 0, 252, 252, 0]
      ball = 15
    when "VGCLEGEND"
      species = :PACHIRISUPLUS
      moves = [:NUZZLE, :FOLLOWME, :SUPERFANG, :PROTECT]
      item = :SITRUSBERRYPLUS
      nature = :IMPISH
      ev_override = [0, 0, 252, 252, 0, 0]
      ball = 15
    when "DRACUTREE"
      species = :TREVENANTPLUS
      moves = [:HORNLEECH, :DRAINPUNCH, :LEECHLIFE, :DIAMONDSTORM]
      item = :PAPERTOWEL
      nature = :ADAMANT
      ev_override = [252, 252, 0, 0, 0, 0]
      ball = 15
    when "STALLYUKU"
      species = :PYUKUMUKUPLUS
      moves = [:MINIMIZE, :TOXIC, :RECOVER, :SOAK]
      item = :LEFTOVERS
      nature = :IMPISH
      ev_override = [252, 0, 252, 0, 0, 0]
      ball = 15
    when "BOLTTHEDOG"
      species = :BOLTUNDPLUS
      moves = [:PLASMAFISTS, :COMBATTORQUE, :THOUSANDARROWS, :FISHIOUSREND]
      item = :ASSAULTVEST
      nature = :JOLLY
      ev_override = [0, 252, 0, 252, 0, 0]
      ball = 15
    when "TERRORGHOST"
      species = :ANNIHILAPEPLUS
      moves = [:CLOSECOMBAT, :PALIZAESPECTRAL, :HEADLONGRUSH, :VCREATE]
      item = :ASSAULTVEST
      nature = :ADAMANT
      ev_override = [0, 252, 0, 252, 0, 0]
      ball = 15
    when "SUMOYAMA"
      species = :IRONHANDSPLUS
      moves = [:STRENGTHSAP, :THUNDEROUSKICK, :KNOCKOFF, :NUZZLE]
      item = :ROCKYHELMET
      nature = :CAREFUL
      ev_override = [0, 252, 0, 0, 0, 252]
      ball = 15
    when "GALLADEVOIR"
      species = :IRONVALIANTPLUS
      moves = [:EXTREMESPEED, :VCREATE, :POPULATIONBOMB, :THUNDEROUSKICK]
      item = :WIDELENS
      nature = :ADAMANT
      ev_override = [0, 252, 0, 252, 0, 0]
      ball = 15
    when "GODSLAYER"
      species = :PIKACHUPLUS
      moves = [:VOLTTACKLE, :WOODHAMMER, :FLAREBLITZ, :BRAVEBIRD]
      item = :LIFEORBPLUS
      nature = :ADAMANT
      ev_override = [0, 252, 0, 252, 0, 0]
      ball = 15
    when "NOCTOBLUE"
      species = :UMBREONPLUS
      moves = [:SPIKYSHIELD, :KNOCKOFF, :PURIFY, :WILLOWISP]
      item = :TOXICORB
      nature = :CAREFUL
      shiny = true
      ev_override = [0, 0, 252, 0, 0, 252]
      ball = 15
    when "FLASHKUDA"
      species = :BARRASKEWDAPLUS
      moves = [:FISHIOUSREND, :GLACIALLANCE, :DIAMONDSTORM, :FLIPTURN]
      item = :CHOICEBAND
      nature = :ADAMANT
      ev_override = [0, 252, 0, 252, 0, 0]
      ball = 15
    when "NANOMACHINES"
      species = :SHUCKLEPLUS
      moves = [:BODYPRESS, :SHUCKLEPRESS, :SHUCKLEPRESSV2, :COTTONGUARD]
      item = :PAPERTOWEL
      nature = :RELAXED
      ev_override = [0, 0, 252, 0, 0, 252]
      ball = 15
    when "KANSEIDORIFTO"
      species = :NINJASKPLUS
      moves = [:BOLTBEAK, :FISHIOUSREND, :DRAINCLAW, :PINZAFLASH]
      item = :PAPERTOWEL
      nature = :JOLLY
      ev_override = [252, 0, 0, 252, 0, 0]
      ball = 15
    when "NOINFORMATION"
      species = :MISSINGNO
      moves = [:HELPINGHAND, :RECOVER, :ASTRALBARRAGE, :JUDGMENT]
      item = :LEFTOVERS
      nature = :CALM
      ev_override = [252, 0, 0, 0, 0, 252]
      ball = 15
    end

    pbMessage("¡Bingo, esa contraseña la conozco! Esto es para ti.")

    poke = PokeBattle_Pokemon.new(species, level, $Trainer)
    poke.makeShiny if shiny
    moves.each { |move| poke.pbLearnMove(move) }
    poke.setItem(item) if item
    poke.setNature(nature) if nature
    poke.iv = [31, 31, 31, 31, 31, 31]
    poke.ev = ev_override || [0, 0, 0, 0, 0, 0]
    poke.ballused = ball if ball

    if custom_ability
      poke.instance_variable_set(:@ability, getID(PBAbilities, custom_ability))
    elsif ability
      poke.setAbility(ability)
    end

    poke.calcStats
    pbAddPokemon(poke)

    # Registrar contraseña usada
    $game_variables[102] << input

    pbMessage("Deber cumplido, uno más a la lista.")
    pbMessage("¡Adiós!")

    return true
  end

  # Opción 2 del evento: revisar contraseñas ya canjeadas
  def self.pbShowRedeemedPasswords
    ensure_store!

    if $game_variables[102].empty?
      pbMessage("Aún no has canjeado ninguna contraseña.")
      return false
    end

    pbMessage("Has canjeado las siguientes contraseñas:")
    $game_variables[102].each do |code|
      desc = PASSWORD_REWARDS[code] || code
      pbMessage("#{desc}")
    end
    return false
  end
end

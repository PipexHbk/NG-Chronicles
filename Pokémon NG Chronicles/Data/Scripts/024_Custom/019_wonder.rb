=begin
*** Wonder Trade Script by Black Eternity ***
This script is to mimic Wonder Trade from an offline perspective.
THERE IS NO ONLINE CAPABILITIES OF THIS SCRIPT,
ALL CALCULATIONS ARE DONE INTERNALLY.

To call the script like normal and have ALL Pokemon trade-able, use the following.
    pbWondertrade(1,[],[])

Black listed Pokemon are to be added to the Exceptions arrays.
  Except is the list of pokemon the player is forbidden to trade.
    Here the player cannot trade any of the following.
      pbWonderTrade(1,[:PIKACHU,:SQUIRTLE,:CHARMANDER,:BULBASAUR],[])
   
  Except2 is the list of pokemon the player is forbidden to receive.
    Here the player cannot receive any of the following.
      pbWonderTrade(1,[],[:MEWTWO,:MEW,:DEOXYS])

The first parameter is the minimum allowed Level of the Pokemon to be traded.
For example, you can not trade a Pokemon through Wonder Trade unless its level
is greater than or equal to specified level.

    pbWonderTrade(40,[:SQUIRTLE,:CHARMANDER,:BULBASAUR],[:MEWTWO,:MEW,:DEOXYS])
    *** Only pokemon over level 40 can be traded, you cannot trade starters.
    *** You cannot receive these legendaries.
   
The fourth parameter, which has recently replaced mej71's "hardobtain"
is called "rare", this parameter developed also by mej71, will use
the Pokemon's rareness and filter the results depending on its values.

** Rareness is turned on by default, if you wish to disable it, call the
    function accordingly.
   
    pbWonderTrade(10,[:SQUIRTLE],[:CHARMANDER,:BULBASAUR],false)
    ** Only Pokemon over level 10, cannot trade Squirtle, cannot
    ** recieve Charmander or Bulbasaur, Rareness disabled.

It is up to you to use it how you wish, credits will be appreciated.
=end

# List of Randomly selected Trainer Names
RandTrainerNames=[
"Clarence",
"James",
"Keith",
"Matthew",
"Jeremy",
"Louis",
"Albert",
"Emily",
"Aaron",
"Frances",
"Steve",
"Joan",
"Dorothy",
"Jeffrey",
"Alice",
"Sara",
"David",
"Anne",
"Shirley",
"Henry",
"Carolyn",
"Christopher",
"Christina",
"Ronald",
"Randy",
"Nancy",
"Virginia",
"Donna",
"William",
"Jacqueline",
"Catherine",
"Jesse",
"Roger",
"Denise",
"Ashley",
"Maria",
"Todd",
"Helen",
"Teresa",
"Fred",
"Annie",
"Rachel",
"Kathleen",
"Marie",
"Scott",
"Phillip",
"Craig",
"Diane",
"Beverly",
"Lisa",
"Mildred",
"Lois",
"Douglas",
"Deborah",
"Phyllis",
"Melissa",
"Laura",
"Stephanie",
"Ernest",
"Evelyn",
"Irene",
"Brandon",
"Jean",
"Sandra",
"Linda",
"Raymond",
"Kathryn",
"Harry",
"Gary",
"Katherine",
"Theresa",
"Howard",
"Stephen",
"Russell",
"Louisel",
"Bobby",
"Susan",
"Martin",
"Harold",
"Andrea",
"Sharon",
"Juan",
"Rose",
"Lori",
"Dorist",
"Joseph",
"Charles",
"Donald",
"Arthur",
"Janice",
"Jack",
"Wanda",
"Ralph",
"Christine",
"Betty",
"Julia",
"Michelle",
"Kevin",
"James",
"Michael",
"Kathy"
]

def pbWonderTrade(lvl=1,except=[],except2=[],rare=true)
  # Convertir nombres internos a IDs
  for i in 0...except.length
    except[i]=getID(PBSpecies,except[i]) if !except[i].is_a?(Integer)
  end
  for i in 0...except2.length
    except2[i]=getID(PBSpecies,except2[i]) if !except2[i].is_a?(Integer)
  end
  
  except+=[]
  
  # Seleccionar Pokémon del jugador
  chosen=pbChoosePokemon(1,2,
  proc {|poke| 
    !poke.egg? && 
    !(poke.isShadow?) && 
    (poke.level>=lvl) && 
    !(except.include?(poke.species))
  })
  
  # Lista de Pokémon que NO se pueden recibir (hardcodeados)
  except2+=[
    :ARTICUNO,:ZAPDOS,:MOLTRES,:MEWTWO,:MEW,:ENTEI,:RAIKOU,:SUICUNE,
    :LUGIA,:HOOH,:CELEBI,:REGIROCK,:REGICE,:LATIOS,:LATIAS,:KYOGRE,:GROUDON,
    :RAYQUAZA,:JIRACHI,:DEOXYS,:HEATRAN,:CRESSELIA,:REGIGIGAS,:UXIE,:MESPRIT,:AZELF,
    :DIALGA,:PALKIA,:GIRATINA,:PHIONE,:MANAPHY,:DARKRAI,:SHAYMIN,:ARCEUS,:COBALION,
    :TERRAKION,:VIRIZION,:KELDEO,:TORNADUS,:LANDORUS,:THUNDURUS,:RESHIRAM,:ZEKROM,
    :KYUREM,:VICTINI,:GENESECT,:XERNEAS,:YVELTAL,:ZYGARDE,:DIANCIE,:HOOPA,:VOLCANION,
    :TYPENULL,:SILVALLY,:TAPUKOKO,:TAPULELE,:TAPUBULU,:TAPUFINI,:COSMOG,:COSMOEM,
    :SOLGALEO,:LUNALA,:NECROZMA,:MAGEARNA,:MARSHADOW,:ZERAORA,:MELTAN,:MELMETAL,
    :KUBFU,:URSHIFU,:GLASTRIER,:SPECTRIER,:REGIELEKI,:REGIDRAGO,:ENAMORUS,:ETERNATUS,
    :CALYREX,:ZACIAN,:ZAMAZENTA,:ZARUDE,:OGERPON,:WOCHIEN,:CHIENPAO,:TINGLU,:CHIYU,
    :OKIDOGI,:MUNKIDORI,:FEZANDIPITI,:KORAIDON,:MIRAIDON,:REGISTEEL,:DRAXOLD,
    :TERAPAGOS,:CHANSEYIMPOSTER,:FERROPLUS,:SHEDINJAPLUS,:SLAKINGPLUS,:XATUPLUS,
    :PACHIRISUPLUS,:TREVENANTPLUS,:PYUKUMUKUPLUS,:BOLTUNDPLUS,:ANNIHILAPEPLUS,
    :URSHIFUAWA,:IRONHANDSPLUS,:IRONVALIANTPLUS,:PIKACHUPLUS,:UMBREONPLUS,
    :BARRASKEWDAPLUS,:SHUCKLEPLUS,:NINJASKPLUS,:MISSINGNO,:GREATTUSK,:SCREAMTAIL,
    :BRUTEBONNET,:FLUTTERMANE,:SLITHERWING,:IRONVALIANT,:SANDYSHOCKS,:IRONTREADS,
    :IRONBUNDLE,:IRONHANDS,:IRONJUGULIS,:IRONMOTH,:IRONTHORNS,:ROARINGMOON,
    :WALKINGWAKE,:IRONLEAVES,:GOUGINGFIRE,:RAGINGBOLT,:IRONBOULDER,:IRONCROWN,
    :PECHARUNT,:GUADALUPO
  ]
  
  # Convertir los Pokémon hardcodeados a IDs
  for i in 0...except2.length
    except2[i]=getID(PBSpecies,except2[i]) if !except2[i].is_a?(Integer)
  end
  
if pbGet(1)>=0
    species=0
    attempts=0
    max_attempts=5000
    
    while (species==0)
      attempts+=1
      if attempts > max_attempts
        Kernel.pbMessage(_INTL("No se pudo encontrar un Pokémon disponible."))
        return -1
      end
      
      species=rand(PBSpecies.maxValue)+1
      
      # Verificar si está en la lista de excepciones
      species=0 if except2.include?(species)
      
      # Sistema de rareza
      if species > 0 && rare==true
        dexdata=pbOpenDexData
        pbDexDataOffset(dexdata,species,16)
        rareness=dexdata.fgetb
        dexdata.close
        species=0 if rand(255)>=rareness
      end
    end
    
    # Nivel aleatorio entre 10 y 30
    nivel_recibido = rand(10..30)
    
    # Nombre aleatorio del entrenador
    tname=RandTrainerNames[rand(RandTrainerNames.size)]
    
    # Guardar el índice del Pokémon que se va a intercambiar
    indice_intercambio = pbGet(1)
    
    # Iniciar el intercambio
    pbStartTrade(indice_intercambio,species,PBSpecies.getName(species),tname)
    
    # Cambiar el nivel del Pokémon recibido DESPUÉS del intercambio
    pokemon_recibido = $Trainer.party[indice_intercambio]
    if pokemon_recibido && pokemon_recibido.species == species
      pokemon_recibido.level = nivel_recibido
      pokemon_recibido.calcStats
      pokemon_recibido.resetMoves
    end
  else
    return -1
  end
end
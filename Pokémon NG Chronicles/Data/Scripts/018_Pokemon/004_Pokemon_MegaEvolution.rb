################################################################################
# Las Mega Evoluciones y Reversiones Primigenias son tratadas como cambios de
# forma en Essentials. El código de abajo es poco más que lo que ya estaba en la
# sección del script Pokemon_MultipleForms, pero específicamente para las
# Mega Evoluciones y Reversiones Primigenias.
################################################################################

# NOTA: Los métodos principales de mega evolución están en PokeBattle_Pokemon
# Este archivo solo contiene las definiciones de MultipleForms

#===============================================================================
# Cambio de movimiento para Mega Zygarde (SOLO fuera de combate)
#===============================================================================
class PokeBattle_Pokemon
  alias __zygarde_mega_form_original form= unless method_defined?(:__zygarde_mega_form_original)
  
  def form=(value)
    oldform = @form
    __zygarde_mega_form_original(value)
    
    # Solo cambiar movimientos fuera de combate al revertir
    if isConst?(@species,PBSpecies,:ZYGARDE)
      # Revertir (forma 3 → 0): Volver a Core Enforcer
      if oldform == 3 && @form == 0
        for i in 0...@moves.length
          if isConst?(@moves[i].id,PBMoves,:NIHILLIGHT)
            @moves[i] = PBMove.new(getID(PBMoves,:COREENFORCER))
            PBDebug.log("[Zygarde] Movimiento cambiado: Nihil Light → Core Enforcer (fuera de combate)")
            break
          end
        end
      end
    end
    
    # CRÍTICO: Forzar reversión para Raichu
    if isConst?(@species,PBSpecies,:RAICHU)
      if (oldform == 2 || oldform == 3) && value == 0
        @form = 0
        calcStats
        PBDebug.log("[Raichu] Forzado a forma 0 desde forma #{oldform}")
      end
    end
  end
end
 
 # Mega Evoluciones XY ############################################################

 MultipleForms.register(:VENUSAUR,{
 "getMegaForm"=>proc{|pokemon|
    next 1 if isConst?(pokemon.item,PBItems,:VENUSAURITE)
    next 2 if isConst?(pokemon.item,PBItems,:VENUSAURITAG)
    next
  },
 "getMegaName"=>proc{|pokemon|
    next _INTL("Mega Venusaur") if pokemon.form==1
    next _INTL("Giga Venusaur") if pokemon.form==2
    next
 },
 "getBaseStats"=>proc{|pokemon|
    next [80,100,123,80,122,120] if pokemon.form==1
    next [160,82,83,80,100,100] if pokemon.form==2
    next
 },
 "getAbilityList"=>proc{|pokemon|
    next [[getID(PBAbilities,:THICKFAT),0]] if pokemon.form==1
    next [[getID(PBAbilities,:GRASSYSURGE),0]] if pokemon.form==2
    next
 },
 "height"=>proc{|pokemon|
    next 24 if pokemon.form==1
    next 48 if pokemon.form==2
    next
 },
 "weight"=>proc{|pokemon|
    next 1555 if pokemon.form==1
    next 3000 if pokemon.form==1
    next
 },
 "getUnmegaForm"=>proc{|pokemon|
   next 0
 }
 })

 MultipleForms.register(:CHARIZARD,{
 "getMegaForm"=>proc{|pokemon|
    next 3 if isConst?(pokemon.item,PBItems,:CHARIZARDITAG)
    next 2 if isConst?(pokemon.item,PBItems,:CHARIZARDITEX)
    next 1 if isConst?(pokemon.item,PBItems,:CHARIZARDITEY)
    next
 },
 "getMegaName"=>proc{|pokemon|
    next _INTL("Giga Charizard") if pokemon.form==3
    next _INTL("Mega Charizard X") if pokemon.form==2
    next _INTL("Mega Charizard Y") if pokemon.form==1
    next
 },
 "getBaseStats"=>proc{|pokemon|
    next [156,84,78,100,109,85] if pokemon.form==3
    next [78,130,111,100,130,85] if pokemon.form==2
    next [78,104,78,100,159,115] if pokemon.form==1
    next
 },
 "type2"=>proc{|pokemon|
    next getID(PBTypes,:DRAGON) if pokemon.form==2
    next
 },
 "getAbilityList"=>proc{|pokemon|
    next [[getID(PBAbilities,:DROUGHT),0]] if pokemon.form==3
    next [[getID(PBAbilities,:TOUGHCLAWS),0]] if pokemon.form==2
    next [[getID(PBAbilities,:DROUGHT),0]] if pokemon.form==1
    next
 },
 "weight"=>proc{|pokemon|
    next 2105 if pokemon.form==3
    next 1105 if pokemon.form==2
    next 1005 if pokemon.form==1
    next
 },
 "getUnmegaForm"=>proc{|pokemon|
   next 0
 }
 })

 MultipleForms.register(:BLASTOISE,{
 "getMegaForm"=>proc{|pokemon|
    next 1 if isConst?(pokemon.item,PBItems,:BLASTOISINITE)
    next 2 if isConst?(pokemon.item,PBItems,:BLASTOISITAG)
    next
 },
 "getMegaName"=>proc{|pokemon|
    next _INTL("Mega Blastoise") if pokemon.form==1
    next _INTL("Giga Blastoise") if pokemon.form==2
    next
 },
 "getBaseStats"=>proc{|pokemon|
    next [79,103,120,78,135,115] if pokemon.form==1
    next [158,83,100,78,85,105] if pokemon.form==2
    next
 },
 "getAbilityList"=>proc{|pokemon|
    next [[getID(PBAbilities,:MEGALAUNCHER),0]] if pokemon.form==1
    next [[getID(PBAbilities,:DRIZZLE),0]] if pokemon.form==2
    next
 },
 "weight"=>proc{|pokemon|
    next 1011 if pokemon.form==1
    next 3022 if pokemon.form==2
    next
 },
 "getUnmegaForm"=>proc{|pokemon|
   next 0
 }
 })

 MultipleForms.register(:ALAKAZAM,{
 "getMegaForm"=>proc{|pokemon|
    next 1 if isConst?(pokemon.item,PBItems,:ALAKAZITE)
    next
 },
 "getBaseStats"=>proc{|pokemon|
    next [55,50,65,150,175,95] if pokemon.form==1
    next
 },
 "getAbilityList"=>proc{|pokemon|
    next [[getID(PBAbilities,:TRACE),0]] if pokemon.form==1
    next
 },
 "height"=>proc{|pokemon|
    next 12 if pokemon.form==1
    next
 },
 "getUnmegaForm"=>proc{|pokemon|
   next 0
 }
 })

 MultipleForms.register(:GENGAR,{
 "getMegaForm"=>proc{|pokemon|
    next 1 if isConst?(pokemon.item,PBItems,:GENGARITE)
    next 2 if isConst?(pokemon.item,PBItems,:GENGARITEG)
    next
  },
 "getMegaName"=>proc{|pokemon|
    next _INTL("Mega Gengar") if pokemon.form==1
    next _INTL("Giga Gengar") if pokemon.form==2
    next
 },
 "getBaseStats"=>proc{|pokemon|
    next [60,65,80,130,170,95] if pokemon.form==1
    next [120,65,60,110,130,75] if pokemon.form==2
    next
 },
 "getAbilityList"=>proc{|pokemon|
    next [[getID(PBAbilities,:SHADOWTAG),0]] if pokemon.form==1
    next [[getID(PBAbilities,:ADAPTABILITY),0]] if pokemon.form==2
    next
 },
 "height"=>proc{|pokemon|
    next 14 if pokemon.form==1
    next 28 if pokemon.form==2
    next
 },
 "getUnmegaForm"=>proc{|pokemon|
   next 0
 }
 })

 MultipleForms.register(:KANGASKHAN,{
 "getMegaForm"=>proc{|pokemon|
    next 1 if isConst?(pokemon.item,PBItems,:KANGASKHANITE)
    next
 },
 "getBaseStats"=>proc{|pokemon|
    next [105,125,100,100,60,100] if pokemon.form==1
    next
 },
 "getAbilityList"=>proc{|pokemon|
    next [[getID(PBAbilities,:PARENTALBOND),0]] if pokemon.form==1
    next
 },
 "weight"=>proc{|pokemon|
    next 1000 if pokemon.form==1
    next
 },
 "getUnmegaForm"=>proc{|pokemon|
   next 0
 }
 })

 MultipleForms.register(:PINSIR,{
 "getMegaForm"=>proc{|pokemon|
    next 1 if isConst?(pokemon.item,PBItems,:PINSIRITE)
    next
 },
 "getBaseStats"=>proc{|pokemon|
    next [65,155,120,105,65,90] if pokemon.form==1
    next
 },
 "type2"=>proc{|pokemon|
    next getID(PBTypes,:FLYING) if pokemon.form==1
    next
 },
 "getAbilityList"=>proc{|pokemon|
    next [[getID(PBAbilities,:AERILATE),0]] if pokemon.form==1
    next
 },
 "height"=>proc{|pokemon|
    next 17 if pokemon.form==1
    next
 },
 "weight"=>proc{|pokemon|
    next 590 if pokemon.form==1
    next
 },
 "getUnmegaForm"=>proc{|pokemon|
   next 0
 }
 })

 MultipleForms.register(:GYARADOS,{
 "getMegaForm"=>proc{|pokemon|
    next 1 if isConst?(pokemon.item,PBItems,:GYARADOSITE)
    next
 },
 "getBaseStats"=>proc{|pokemon|
    next [95,155,109,81,70,130] if pokemon.form==1
    next
 },
 "type2"=>proc{|pokemon|
    next getID(PBTypes,:DARK) if pokemon.form==1
    next
 },
 "getAbilityList"=>proc{|pokemon|
    next [[getID(PBAbilities,:MOLDBREAKER),0]] if pokemon.form==1
    next
 },
 "weight"=>proc{|pokemon|
    next 3050 if pokemon.form==1
    next
 },
 "getUnmegaForm"=>proc{|pokemon|
   next 0
 }
 })

 MultipleForms.register(:AERODACTYL,{
 "getMegaForm"=>proc{|pokemon|
    next 1 if isConst?(pokemon.item,PBItems,:AERODACTYLITE)
    next
 },
 "getBaseStats"=>proc{|pokemon|
    next [80,135,85,150,70,95] if pokemon.form==1
    next
 },
 "getAbilityList"=>proc{|pokemon|
    next [[getID(PBAbilities,:TOUGHCLAWS),0]] if pokemon.form==1
    next
 },
 "height"=>proc{|pokemon|
    next 21 if pokemon.form==1
    next
 },
 "weight"=>proc{|pokemon|
    next 790 if pokemon.form==1
    next
 },
 "getUnmegaForm"=>proc{|pokemon|
   next 0
 }
 })

 MultipleForms.register(:MEWTWO,{
 "getMegaForm"=>proc{|pokemon|
    next 2 if isConst?(pokemon.item,PBItems,:MEWTWONITEX)
    next 1 if isConst?(pokemon.item,PBItems,:MEWTWONITEY)
    next
 },
 "getMegaName"=>proc{|pokemon|
    next _INTL("Mega Mewtwo X") if pokemon.form==2
    next _INTL("Mega Mewtwo Y") if pokemon.form==1
    next
 },
 "getBaseStats"=>proc{|pokemon|
    next [106,190,100,130,154,100] if pokemon.form==2
    next [106,150,70,140,194,120] if pokemon.form==1
    next
 },
 "type2"=>proc{|pokemon|
    next getID(PBTypes,:FIGHTING) if pokemon.form==2
    next
 },
 "getAbilityList"=>proc{|pokemon|
    next [[getID(PBAbilities,:STEADFAST),0]] if pokemon.form==2
    next [[getID(PBAbilities,:INSOMNIA),0]] if pokemon.form==1
    next
 },
 "height"=>proc{|pokemon|
    next 23 if pokemon.form==2
    next 15 if pokemon.form==1
    next
 },
 "weight"=>proc{|pokemon|
    next 1270 if pokemon.form==2
    next 330 if pokemon.form==1
    next
 },
 "getUnmegaForm"=>proc{|pokemon|
   next 0
 }
 })

 MultipleForms.register(:AMPHAROS,{
 "getMegaForm"=>proc{|pokemon|
    next 1 if isConst?(pokemon.item,PBItems,:AMPHAROSITE)
    next
 },
 "getBaseStats"=>proc{|pokemon|
    next [90,95,105,45,165,110] if pokemon.form==1
    next
 },
 "type2"=>proc{|pokemon|
    next getID(PBTypes,:DRAGON) if pokemon.form==1
    next
 },
 "getAbilityList"=>proc{|pokemon|
    next [[getID(PBAbilities,:MOLDBREAKER),0]] if pokemon.form==1
    next
 },
 "getUnmegaForm"=>proc{|pokemon|
   next 0
 }
 })

 MultipleForms.register(:SCIZOR,{
 "getMegaForm"=>proc{|pokemon|
    next 1 if isConst?(pokemon.item,PBItems,:SCIZORITE)
    next
 },
 "getBaseStats"=>proc{|pokemon|
    next [70,150,140,75,65,100] if pokemon.form==1
    next
 },
 "getAbilityList"=>proc{|pokemon|
    next [[getID(PBAbilities,:TECHNICIAN),0]] if pokemon.form==1
    next
 },
 "height"=>proc{|pokemon|
    next 20 if pokemon.form==1
    next
 },
 "weight"=>proc{|pokemon|
    next 1250 if pokemon.form==1
    next
 },
 "getUnmegaForm"=>proc{|pokemon|
   next 0
 }
 })

 MultipleForms.register(:HERACROSS,{
 "getMegaForm"=>proc{|pokemon|
    next 1 if isConst?(pokemon.item,PBItems,:HERACRONITE)
    next
 },
 "getBaseStats"=>proc{|pokemon|
    next [80,185,115,75,40,105] if pokemon.form==1
    next
 },
 "getAbilityList"=>proc{|pokemon|
    next [[getID(PBAbilities,:SKILLLINK),0]] if pokemon.form==1
    next
 },
 "height"=>proc{|pokemon|
    next 17 if pokemon.form==1
    next
 },
 "weight"=>proc{|pokemon|
    next 625 if pokemon.form==1
    next
 },
 "getUnmegaForm"=>proc{|pokemon|
   next 0
 }
 })

 MultipleForms.register(:HOUNDOOM,{
 "getMegaForm"=>proc{|pokemon|
    next 1 if isConst?(pokemon.item,PBItems,:HOUNDOOMINITE)
    next
 },
 "getBaseStats"=>proc{|pokemon|
    next [75,90,90,115,140,90] if pokemon.form==1
    next
 },
 "getAbilityList"=>proc{|pokemon|
    next [[getID(PBAbilities,:SOLARPOWER),0]] if pokemon.form==1
    next
 },
 "height"=>proc{|pokemon|
    next 19 if pokemon.form==1
    next
 },
 "weight"=>proc{|pokemon|
    next 495 if pokemon.form==1
    next
 },
 "getUnmegaForm"=>proc{|pokemon|
   next 0
 }
 })

 MultipleForms.register(:TYRANITAR,{
 "getMegaForm"=>proc{|pokemon|
    next 1 if isConst?(pokemon.item,PBItems,:TYRANITARITE)
    next
 },
 "getBaseStats"=>proc{|pokemon|
    next [100,164,150,71,95,120] if pokemon.form==1
    next
 },
 "getAbilityList"=>proc{|pokemon|
    next [[getID(PBAbilities,:SANDSTREAM),0]] if pokemon.form==1
    next
 },
 "height"=>proc{|pokemon|
    next 25 if pokemon.form==1
    next
 },
 "weight"=>proc{|pokemon|
    next 2550 if pokemon.form==1
    next
 },
 "getUnmegaForm"=>proc{|pokemon|
   next 0
 }
 })

 MultipleForms.register(:BLAZIKEN,{
 "getMegaForm"=>proc{|pokemon|
    next 1 if isConst?(pokemon.item,PBItems,:BLAZIKENITE)
    next
 },
 "getBaseStats"=>proc{|pokemon|
    next [80,160,80,100,130,80] if pokemon.form==1
    next
 },
 "getAbilityList"=>proc{|pokemon|
    next [[getID(PBAbilities,:SPEEDBOOST),0]] if pokemon.form==1
    next
 },
 "getUnmegaForm"=>proc{|pokemon|
   next 0
 }
 })

 MultipleForms.register(:GARDEVOIR,{
 "getMegaForm"=>proc{|pokemon|
    next 1 if isConst?(pokemon.item,PBItems,:GARDEVOIRITE)
    next
 },
 "getBaseStats"=>proc{|pokemon|
    next [68,85,65,100,165,135] if pokemon.form==1
    next
 },
 "getAbilityList"=>proc{|pokemon|
    next [[getID(PBAbilities,:PIXILATE),0]] if pokemon.form==1
    next
 },
 "getUnmegaForm"=>proc{|pokemon|
   next 0
 }
 })

 MultipleForms.register(:MAWILE,{
 "getMegaForm"=>proc{|pokemon|
    next 1 if isConst?(pokemon.item,PBItems,:MAWILITE)
    next
 },
 "getBaseStats"=>proc{|pokemon|
    next [70,140,90,100,30,90] if pokemon.form==1
    next
 },
 "getAbilityList"=>proc{|pokemon|
    next [[getID(PBAbilities,:HUGEPOWER),0]] if pokemon.form==1
    next
 },
 "height"=>proc{|pokemon|
    next 10 if pokemon.form==1
    next
 },
 "weight"=>proc{|pokemon|
    next 235 if pokemon.form==1
    next
 },
 "getUnmegaForm"=>proc{|pokemon|
   next 0
 }
 })

 MultipleForms.register(:AGGRON,{
 "getMegaForm"=>proc{|pokemon|
    next 1 if isConst?(pokemon.item,PBItems,:AGGRONITE)
    next
 },
 "getBaseStats"=>proc{|pokemon|
    next [70,140,230,50,60,80] if pokemon.form==1
    next
 },
 "type2"=>proc{|pokemon|
    next getID(PBTypes,:STEEL) if pokemon.form==1
    next
 },
 "getAbilityList"=>proc{|pokemon|
    next [[getID(PBAbilities,:FILTER),0]] if pokemon.form==1
    next
 },
 "height"=>proc{|pokemon|
    next 22 if pokemon.form==1
    next
 },
 "weight"=>proc{|pokemon|
    next 3950 if pokemon.form==1
    next
 },
 "getUnmegaForm"=>proc{|pokemon|
   next 0
 }
 })

 MultipleForms.register(:MEDICHAM,{
 "getMegaForm"=>proc{|pokemon|
    next 1 if isConst?(pokemon.item,PBItems,:MEDICHAMITE)
    next
 },
 "getBaseStats"=>proc{|pokemon|
    next [60,100,85,100,80,85] if pokemon.form==1
    next
 },
 "getAbilityList"=>proc{|pokemon|
    next [[getID(PBAbilities,:PUREPOWER),0]] if pokemon.form==1
    next
 },
 "getUnmegaForm"=>proc{|pokemon|
   next 0
 }
 })

 MultipleForms.register(:MANECTRIC,{
 "getMegaForm"=>proc{|pokemon|
    next 1 if isConst?(pokemon.item,PBItems,:MANECTITE)
    next
 },
 "getBaseStats"=>proc{|pokemon|
    next [70,75,80,135,135,80] if pokemon.form==1
    next
 },
 "getAbilityList"=>proc{|pokemon|
    next [[getID(PBAbilities,:INTIMIDATE),0]] if pokemon.form==1
    next
 },
 "height"=>proc{|pokemon|
    next 18 if pokemon.form==1
    next
 },
 "weight"=>proc{|pokemon|
    next 440 if pokemon.form==1
    next
 },
 "getUnmegaForm"=>proc{|pokemon|
   next 0
 }
 })

 MultipleForms.register(:BANETTE,{
 "getMegaForm"=>proc{|pokemon|
    next 1 if isConst?(pokemon.item,PBItems,:BANETTITE)
    next
 },
 "getBaseStats"=>proc{|pokemon|
    next [64,165,75,75,93,83] if pokemon.form==1
    next
 },
 "getAbilityList"=>proc{|pokemon|
    next [[getID(PBAbilities,:PRANKSTER),0]] if pokemon.form==1
    next
 },
 "height"=>proc{|pokemon|
    next 12 if pokemon.form==1
    next
 },
 "weight"=>proc{|pokemon|
    next 130 if pokemon.form==1
    next
 },
 "getUnmegaForm"=>proc{|pokemon|
   next 0
 }
 })

MultipleForms.register(:ABSOL,{
"getMegaForm"=>proc{|pokemon|
   next 2 if isConst?(pokemon.item,PBItems,:ABSOLITAZ)
   next 1 if isConst?(pokemon.item,PBItems,:ABSOLITE)
   next
},
"getMegaName"=>proc{|pokemon|
   next _INTL("Mega Absol Z") if pokemon.form==2
   next _INTL("Mega Absol") if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next [75,164,80,151,75,80] if pokemon.form==2  # Mega Absol Z
   next [75,180,90,120,80,80] if pokemon.form==1  # Mega Absol
   next
},
"type2"=>proc{|pokemon|
   next getID(PBTypes,:GHOST) if pokemon.form==2  # Dark/Ghost
   next
},
"getAbilityList"=>proc{|pokemon|
   next [[getID(PBAbilities,:SHADOWSHIELD),0]] if pokemon.form==2
   next [[getID(PBAbilities,:MAGICBOUNCE),0]] if pokemon.form==1
   next
},
"height"=>proc{|pokemon|
   next 11 if pokemon.form==2
   next 11 if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 490 if pokemon.form==2
   next 490 if pokemon.form==1
   next
},
"getUnmegaForm"=>proc{|pokemon|
  next 0
}
})

MultipleForms.register(:GARCHOMP,{
"getMegaForm"=>proc{|pokemon|
   next 2 if isConst?(pokemon.item,PBItems,:GARCHOMPITAZ)
   next 1 if isConst?(pokemon.item,PBItems,:GARCHOMPITE)
   next
},
"getMegaName"=>proc{|pokemon|
   next _INTL("Mega Garchomp Z") if pokemon.form==2
   next _INTL("Mega Garchomp") if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next [108,130,85,151,141,85] if pokemon.form==2  # Mega Garchomp Z
   next [108,170,115,92,120,95] if pokemon.form==1  # Mega Garchomp
   next
},
"type1"=>proc{|pokemon|
   next getID(PBTypes,:DRAGON) if pokemon.form==2  # Solo Dragón
   next
},
"type2"=>proc{|pokemon|
   next if pokemon.form==2  # Sin tipo secundario
   next
},
"getAbilityList"=>proc{|pokemon|
   next [[getID(PBAbilities,:COMPETITIVE),0]] if pokemon.form==2
   next [[getID(PBAbilities,:SANDFORCE),0]] if pokemon.form==1
   next
},
"getUnmegaForm"=>proc{|pokemon|
  next 0
}
})

MultipleForms.register(:LUCARIO,{
"getMegaForm"=>proc{|pokemon|
   next 2 if isConst?(pokemon.item,PBItems,:LUCARITAZ)
   next 1 if isConst?(pokemon.item,PBItems,:LUCARIONITE)
   next
},
"getMegaName"=>proc{|pokemon|
   next _INTL("Mega Lucario Z") if pokemon.form==2
   next _INTL("Mega Lucario") if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next [70,100,70,151,164,70] if pokemon.form==2  # Mega Lucario Z
   next [70,145,88,112,140,70] if pokemon.form==1  # Mega Lucario
   next
},
"getAbilityList"=>proc{|pokemon|
   next [[getID(PBAbilities,:BERSERK),0]] if pokemon.form==2
   next [[getID(PBAbilities,:ADAPTABILITY),0]] if pokemon.form==1
   next
},
"height"=>proc{|pokemon|
   next 13 if pokemon.form==2
   next 13 if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 575 if pokemon.form==2
   next 575 if pokemon.form==1
   next
},
"getUnmegaForm"=>proc{|pokemon|
  next 0
}
})

 MultipleForms.register(:ABOMASNOW,{
 "getMegaForm"=>proc{|pokemon|
    next 1 if isConst?(pokemon.item,PBItems,:ABOMASITE)
    next
 },
 "getBaseStats"=>proc{|pokemon|
    next [90,132,105,30,132,105] if pokemon.form==1
    next
 },
 "getAbilityList"=>proc{|pokemon|
    next [[getID(PBAbilities,:SNOWWARNING),0]] if pokemon.form==1
    next
 },
 "height"=>proc{|pokemon|
    next 27 if pokemon.form==1
    next
 },
 "weight"=>proc{|pokemon|
    next 1850 if pokemon.form==1
    next
 },
 "getUnmegaForm"=>proc{|pokemon|
   next 0
 }
 })

 # Mega Evoluciones ORAS ##########################################################

 MultipleForms.register(:BEEDRILL,{
 "getMegaForm"=>proc{|pokemon|
    next 1 if isConst?(pokemon.item,PBItems,:BEEDRILLITE)
    next
 },
 "getBaseStats"=>proc{|pokemon|
    next [65,150,40,145,15,80] if pokemon.form==1
    next
 },
 "getAbilityList"=>proc{|pokemon|
    next [[getID(PBAbilities,:ADAPTABILITY),0]] if pokemon.form==1
    next
 },
 "height"=>proc{|pokemon|
    next 14 if pokemon.form==1
    next
 },
 "weight"=>proc{|pokemon|
    next 405 if pokemon.form==1
    next
 },
 "getUnmegaForm"=>proc{|pokemon|
   next 0
 }
 })

 MultipleForms.register(:PIDGEOT,{
 "getMegaForm"=>proc{|pokemon|
    next 1 if isConst?(pokemon.item,PBItems,:PIDGEOTITE)
    next
 },
 "getBaseStats"=>proc{|pokemon|
    next [83,80,80,121,135,80] if pokemon.form==1
    next
 },
 "getAbilityList"=>proc{|pokemon|
    next [[getID(PBAbilities,:NOGUARD),0]] if pokemon.form==1
    next
 },
 "height"=>proc{|pokemon|
    next 22 if pokemon.form==1
    next
 },
 "weight"=>proc{|pokemon|
    next 505 if pokemon.form==1
    next
 },
 "getUnmegaForm"=>proc{|pokemon|
   next 0
 }
 })

 MultipleForms.register(:STEELIX,{
 "getMegaForm"=>proc{|pokemon|
    next 1 if isConst?(pokemon.item,PBItems,:STEELIXITE)
    next
 },
 "getBaseStats"=>proc{|pokemon|
    next [75,125,230,30,55,95] if pokemon.form==1
    next
 },
 "getAbilityList"=>proc{|pokemon|
    next [[getID(PBAbilities,:SANDFORCE),0]] if pokemon.form==1
    next
 },
 "height"=>proc{|pokemon|
    next 105 if pokemon.form==1
    next
 },
 "weight"=>proc{|pokemon|
    next 7400 if pokemon.form==1
    next
 },
 "getUnmegaForm"=>proc{|pokemon|
   next 0
 }
 })

 MultipleForms.register(:SCEPTILE,{
 "getMegaForm"=>proc{|pokemon|
    next 1 if isConst?(pokemon.item,PBItems,:SCEPTILITE)
    next
 },
 "getBaseStats"=>proc{|pokemon|
    next [70,145,75,145,110,85] if pokemon.form==1
    next
 },
 "type2"=>proc{|pokemon|
    next getID(PBTypes,:DRAGON) if pokemon.form==1
    next
 },
 "getAbilityList"=>proc{|pokemon|
    next [[getID(PBAbilities,:TECHNICIAN),0]] if pokemon.form==1
    next
 },
 "height"=>proc{|pokemon|
    next 19 if pokemon.form==1
    next
 },
 "weight"=>proc{|pokemon|
    next 552 if pokemon.form==1
    next
 },
 "getUnmegaForm"=>proc{|pokemon|
   next 0
 }
 })

 MultipleForms.register(:SWAMPERT,{
 "getMegaForm"=>proc{|pokemon|
    next 1 if isConst?(pokemon.item,PBItems,:SWAMPERTITE)
    next
 },
 "getBaseStats"=>proc{|pokemon|
    next [100,160,110,90,95,110] if pokemon.form==1
    next
 },
 "getAbilityList"=>proc{|pokemon|
    next [[getID(PBAbilities,:SWIFTSWIM),0]] if pokemon.form==1
    next
 },
 "height"=>proc{|pokemon|
    next 19 if pokemon.form==1
    next
 },
 "weight"=>proc{|pokemon|
    next 1020 if pokemon.form==1
    next
 },
 "getUnmegaForm"=>proc{|pokemon|
   next 0
 }
 })

 MultipleForms.register(:SABLEYE,{
 "getMegaForm"=>proc{|pokemon|
    next 1 if isConst?(pokemon.item,PBItems,:SABLENITE)
    next
 },
 "getBaseStats"=>proc{|pokemon|
    next [50,85,125,20,85,115] if pokemon.form==1
    next
 },
 "getAbilityList"=>proc{|pokemon|
    next [[getID(PBAbilities,:PRANKSTER),0]] if pokemon.form==1
    next
 },
 "weight"=>proc{|pokemon|
    next 1610 if pokemon.form==1
    next
 },
 "getUnmegaForm"=>proc{|pokemon|
   next 0
 }
 })

 MultipleForms.register(:SHARPEDO,{
 "getMegaForm"=>proc{|pokemon|
    next 1 if isConst?(pokemon.item,PBItems,:SHARPEDONITE)
    next
 },
 "getBaseStats"=>proc{|pokemon|
    next [70,140,70,105,110,65] if pokemon.form==1
    next
 },
 "getAbilityList"=>proc{|pokemon|
    next [[getID(PBAbilities,:STRONGJAW),0]] if pokemon.form==1
    next
 },
 "height"=>proc{|pokemon|
    next 25 if pokemon.form==1
    next
 },
 "weight"=>proc{|pokemon|
    next 1303 if pokemon.form==1
    next
 },
 "getUnmegaForm"=>proc{|pokemon|
   next 0
 }
 })

 MultipleForms.register(:CAMERUPT,{
 "getMegaForm"=>proc{|pokemon|
    next 1 if isConst?(pokemon.item,PBItems,:CAMERUPTITE)
    next
 },
 "getBaseStats"=>proc{|pokemon|
    next [70,120,100,20,145,105] if pokemon.form==1
    next
 },
 "getAbilityList"=>proc{|pokemon|
    next [[getID(PBAbilities,:SHEERFORCE),0]] if pokemon.form==1
    next
 },
 "height"=>proc{|pokemon|
    next 25 if pokemon.form==1
    next
 },
 "weight"=>proc{|pokemon|
    next 3205 if pokemon.form==1
    next
 },
 "getUnmegaForm"=>proc{|pokemon|
   next 0
 }
 })

 MultipleForms.register(:ALTARIA,{
 "getMegaForm"=>proc{|pokemon|
    next 1 if isConst?(pokemon.item,PBItems,:ALTARIANITE)
    next
 },
 "getBaseStats"=>proc{|pokemon|
    next [75,110,110,80,110,105] if pokemon.form==1
    next
 },
 "type2"=>proc{|pokemon|
    next getID(PBTypes,:FAIRY) if pokemon.form==1
    next
 },
 "getAbilityList"=>proc{|pokemon|
    next [[getID(PBAbilities,:PIXILATE),0]] if pokemon.form==1
    next
 },
 "height"=>proc{|pokemon|
    next 15 if pokemon.form==1
    next
 },
 "getUnmegaForm"=>proc{|pokemon|
   next 0
 }
 })

 MultipleForms.register(:GLALIE,{
 "getMegaForm"=>proc{|pokemon|
    next 1 if isConst?(pokemon.item,PBItems,:GLALITITE)
    next
 },
 "getBaseStats"=>proc{|pokemon|
    next [80,120,80,100,120,80] if pokemon.form==1
    next
 },
 "getAbilityList"=>proc{|pokemon|
    next [[getID(PBAbilities,:REFRIGERATE),0]] if pokemon.form==1
    next
 },
 "height"=>proc{|pokemon|
    next 21 if pokemon.form==1
    next
 },
 "weight"=>proc{|pokemon|
    next 3502 if pokemon.form==1
    next
 },
 "getUnmegaForm"=>proc{|pokemon|
   next 0
 }
 })

 MultipleForms.register(:SALAMENCE,{
 "getMegaForm"=>proc{|pokemon|
    next 1 if isConst?(pokemon.item,PBItems,:SALAMENCITE)
    next
 },
 "getBaseStats"=>proc{|pokemon|
    next [95,145,130,120,120,90] if pokemon.form==1
    next
 },
 "getAbilityList"=>proc{|pokemon|
    next [[getID(PBAbilities,:AERILATE),0]] if pokemon.form==1
    next
 },
 "height"=>proc{|pokemon|
    next 18 if pokemon.form==1
    next
 },
 "weight"=>proc{|pokemon|
    next 1126 if pokemon.form==1
    next
 },
 "getUnmegaForm"=>proc{|pokemon|
   next 0
 }
 })

 MultipleForms.register(:METAGROSS,{
 "getMegaForm"=>proc{|pokemon|
    next 1 if isConst?(pokemon.item,PBItems,:METAGROSSITE)
    next
 },
 "getBaseStats"=>proc{|pokemon|
    next [80,145,150,110,105,110] if pokemon.form==1
    next
 },
 "getAbilityList"=>proc{|pokemon|
    next [[getID(PBAbilities,:TOUGHCLAWS),0]] if pokemon.form==1
    next
 },
 "height"=>proc{|pokemon|
    next 25 if pokemon.form==1
    next
 },
 "weight"=>proc{|pokemon|
    next 9429 if pokemon.form==1
    next
 },
 "getUnmegaForm"=>proc{|pokemon|
   next 0
 }
 })

 MultipleForms.register(:LATIAS,{
 "getMegaForm"=>proc{|pokemon|
    next 1 if isConst?(pokemon.item,PBItems,:LATIASITE)
    next
 },
 "getBaseStats"=>proc{|pokemon|
    next [80,100,120,110,140,150] if pokemon.form==1
    next
 },
 "height"=>proc{|pokemon|
    next 18 if pokemon.form==1
    next
 },
 "weight"=>proc{|pokemon|
    next 520 if pokemon.form==1
    next
 },
 "getUnmegaForm"=>proc{|pokemon|
   next 0
 }
 })

 MultipleForms.register(:LATIOS,{
 "getMegaForm"=>proc{|pokemon|
    next 1 if isConst?(pokemon.item,PBItems,:LATIOSITE)
    next
 },
 "getBaseStats"=>proc{|pokemon|
    next [80,130,100,110,160,120] if pokemon.form==1
    next
 },
 "height"=>proc{|pokemon|
    next 23 if pokemon.form==1
    next
 },
 "weight"=>proc{|pokemon|
    next 700 if pokemon.form==1
    next
 },
 "getUnmegaForm"=>proc{|pokemon|
   next 0
 }
 })

 MultipleForms.register(:RAYQUAZA,{
 "getMegaForm"=>proc{|pokemon|
    next 1 if pokemon.hasMove?(:DRAGONASCENT)
    next
 },
 "megaMessage"=>proc{|pokemon|
    next 1
 },
 "getBaseStats"=>proc{|pokemon|
    next [105,180,100,115,180,100] if pokemon.form==1
    next
 },
 "getAbilityList"=>proc{|pokemon|
    next [[getID(PBAbilities,:DELTASTREAM),0]] if pokemon.form==1
    next
 },
 "height"=>proc{|pokemon|
    next 108 if pokemon.form==1
    next
 },
 "weight"=>proc{|pokemon|
    next 3920 if pokemon.form==1
    next
 },
 "getUnmegaForm"=>proc{|pokemon|
   next 0
 }
 })

 MultipleForms.register(:LOPUNNY,{
 "getMegaForm"=>proc{|pokemon|
    next 1 if isConst?(pokemon.item,PBItems,:LOPUNNITE)
    next
 },
 "getBaseStats"=>proc{|pokemon|
    next [65,136,94,135,54,96] if pokemon.form==1
    next
 },
 "type2"=>proc{|pokemon|
    next getID(PBTypes,:FIGHTING) if pokemon.form==1
    next
 },
 "getAbilityList"=>proc{|pokemon|
    next [[getID(PBAbilities,:SCRAPPY),0]] if pokemon.form==1
    next
 },
 "height"=>proc{|pokemon|
    next 13 if pokemon.form==1
    next
 },
 "weight"=>proc{|pokemon|
    next 283 if pokemon.form==1
    next
 },
 "getUnmegaForm"=>proc{|pokemon|
   next 0
 }
 })

 MultipleForms.register(:GALLADE,{
 "getMegaForm"=>proc{|pokemon|
    next 1 if isConst?(pokemon.item,PBItems,:GALLADITE)
    next
 },
 "getBaseStats"=>proc{|pokemon|
    next [68,165,95,110,65,115] if pokemon.form==1
    next
 },
 "getAbilityList"=>proc{|pokemon|
    next [[getID(PBAbilities,:INNERFOCUS),0]] if pokemon.form==1
    next
 },
 "weight"=>proc{|pokemon|
    next 564 if pokemon.form==1
    next
 },
 "getUnmegaForm"=>proc{|pokemon|
   next 0
 }
 })

 MultipleForms.register(:AUDINO,{
 "getMegaForm"=>proc{|pokemon|
    next 1 if isConst?(pokemon.item,PBItems,:AUDINITE)
    next
 },
 "getBaseStats"=>proc{|pokemon|
    next [103,60,126,50,80,126] if pokemon.form==1
    next
 },
 "type2"=>proc{|pokemon|
    next getID(PBTypes,:FAIRY) if pokemon.form==1
    next
 },
 "getAbilityList"=>proc{|pokemon|
    next [[getID(PBAbilities,:HEALER),0]] if pokemon.form==1
    next
 },
 "height"=>proc{|pokemon|
    next 15 if pokemon.form==1
    next
 },
 "weight"=>proc{|pokemon|
    next 320 if pokemon.form==1
    next
 },
 "getUnmegaForm"=>proc{|pokemon|
   next 0
 }
 })

 MultipleForms.register(:DIANCIE,{
 "getMegaForm"=>proc{|pokemon|
    next 1 if isConst?(pokemon.item,PBItems,:DIANCITE)
    next
 },
 "getBaseStats"=>proc{|pokemon|
    next [50,160,110,110,160,110] if pokemon.form==1
    next
 },
 "getAbilityList"=>proc{|pokemon|
    next [[getID(PBAbilities,:MAGICBOUNCE),0]] if pokemon.form==1
    next
 },
 "height"=>proc{|pokemon|
    next 11 if pokemon.form==1
    next
 },
 "weight"=>proc{|pokemon|
    next 278 if pokemon.form==1
    next
 },
 "getUnmegaForm"=>proc{|pokemon|
   next 0
 }
 })

 MultipleForms.register(:FLYGON,{
 "getMegaForm"=>proc{|pokemon|
    next 1 if isConst?(pokemon.item,PBItems,:FLYGONITA)
    next
 },
 "getBaseStats"=>proc{|pokemon|
    next [90,160,95,120,100,95] if pokemon.form==1
    next
 },
 "getAbilityList"=>proc{|pokemon|
    next [[getID(PBAbilities,:SANDRUSH),0]] if pokemon.form==1
    next
 },
 "height"=>proc{|pokemon|
    next 11 if pokemon.form==1
    next
 },
 "weight"=>proc{|pokemon|
    next 278 if pokemon.form==1
    next
 },
 "getUnmegaForm"=>proc{|pokemon|
   next 0
 }
 })
 
  MultipleForms.register(:VILEPLUME,{
 "getMegaForm"=>proc{|pokemon|
    next 1 if isConst?(pokemon.item,PBItems,:VILEPLUMITA)
    next
 },
 "getBaseStats"=>proc{|pokemon|
    next [100,50,145,50,120,145] if pokemon.form==1
    next
 },
 "getAbilityList"=>proc{|pokemon|
    next [[getID(PBAbilities,:SEEDSOWER),0]] if pokemon.form==1
    next
 },
 "height"=>proc{|pokemon|
    next 11 if pokemon.form==1
    next
 },
 "weight"=>proc{|pokemon|
    next 278 if pokemon.form==1
    next
 },
 "getUnmegaForm"=>proc{|pokemon|
   next 0
 }
 })
 
   MultipleForms.register(:BUTTERFREE,{
 "getMegaForm"=>proc{|pokemon|
    next 1 if isConst?(pokemon.item,PBItems,:BUTTERFRITA)
    next
 },
 "getBaseStats"=>proc{|pokemon|
    next [70,50,65,100,140,95] if pokemon.form==1
    next
 },
 "getAbilityList"=>proc{|pokemon|
    next [[getID(PBAbilities,:GALEWINGS),0]] if pokemon.form==1
    next
 },
 "height"=>proc{|pokemon|
    next 11 if pokemon.form==1
    next
 },
 "weight"=>proc{|pokemon|
    next 278 if pokemon.form==1
    next
 },
 "getUnmegaForm"=>proc{|pokemon|
   next 0
 }
 })
 
    MultipleForms.register(:PIKACHU,{
 "getMegaForm"=>proc{|pokemon|
    next 1 if isConst?(pokemon.item,PBItems,:PIKACHUITA)
    next
 },
 "getBaseStats"=>proc{|pokemon|
    next [80,80,80,120,80,80] if pokemon.form==1
    next
 },
 "getAbilityList"=>proc{|pokemon|
    next [[getID(PBAbilities,:ELECTRICSURGE),0]] if pokemon.form==1
    next
 },
 "height"=>proc{|pokemon|
    next 11 if pokemon.form==1
    next
 },
 "weight"=>proc{|pokemon|
    next 278 if pokemon.form==1
    next
 },
 "getUnmegaForm"=>proc{|pokemon|
   next 0
 }
 })
 
     MultipleForms.register(:KINGLER,{
 "getMegaForm"=>proc{|pokemon|
    next 1 if isConst?(pokemon.item,PBItems,:KINGLERITA)
    next
 },
 "getBaseStats"=>proc{|pokemon|
    next [70,140,130,100,10,70] if pokemon.form==1
    next
 },
 "getAbilityList"=>proc{|pokemon|
    next [[getID(PBAbilities,:VOLTABSORB),0]] if pokemon.form==1
    next
 },
 "height"=>proc{|pokemon|
    next 11 if pokemon.form==1
    next
 },
 "weight"=>proc{|pokemon|
    next 278 if pokemon.form==1
    next
 },
 "getUnmegaForm"=>proc{|pokemon|
   next 0
 }
 })
 
      MultipleForms.register(:LAPRAS,{
 "getMegaForm"=>proc{|pokemon|
    next 1 if isConst?(pokemon.item,PBItems,:LAPRASITA)
    next
 },
 "getBaseStats"=>proc{|pokemon|
    next [150,70,100,70,110,100] if pokemon.form==1
    next
 },
 "getAbilityList"=>proc{|pokemon|
    next [[getID(PBAbilities,:SOLIDROCK),0]] if pokemon.form==1
    next
 },
 "height"=>proc{|pokemon|
    next 11 if pokemon.form==1
    next
 },
 "weight"=>proc{|pokemon|
    next 278 if pokemon.form==1
    next
 },
 "getUnmegaForm"=>proc{|pokemon|
   next 0
 }
 })
 
       MultipleForms.register(:EEVEE,{
 "getMegaForm"=>proc{|pokemon|
    next 1 if isConst?(pokemon.item,PBItems,:EEVEEITA)
    next
 },
 "getBaseStats"=>proc{|pokemon|
    next [100,90,120,60,65,120] if pokemon.form==1
    next
 },
 "getAbilityList"=>proc{|pokemon|
    next [[getID(PBAbilities,:FLUFFY),0]] if pokemon.form==1
    next
 },
 "height"=>proc{|pokemon|
    next 11 if pokemon.form==1
    next
 },
 "weight"=>proc{|pokemon|
    next 278 if pokemon.form==1
    next
 },
 "getUnmegaForm"=>proc{|pokemon|
   next 0
 }
 })
 
        MultipleForms.register(:GARBODOR,{
 "getMegaForm"=>proc{|pokemon|
    next 1 if isConst?(pokemon.item,PBItems,:GARBODORITA)
    next
 },
 "getBaseStats"=>proc{|pokemon|
    next [100,110,90,70,65,90] if pokemon.form==1
    next
 },
 "getAbilityList"=>proc{|pokemon|
    next [[getID(PBAbilities,:PRESSURE),0]] if pokemon.form==1
    next
 },
 "height"=>proc{|pokemon|
    next 11 if pokemon.form==1
    next
 },
 "weight"=>proc{|pokemon|
    next 278 if pokemon.form==1
    next
 },
 "getUnmegaForm"=>proc{|pokemon|
   next 0
 }
 })
 
         MultipleForms.register(:MELMETAL,{
 "getMegaForm"=>proc{|pokemon|
    next 1 if isConst?(pokemon.item,PBItems,:MELMETANITA)
    next
 },
 "getBaseStats"=>proc{|pokemon|
    next [150,163,163,100,45,34] if pokemon.form==1
    next
 },
 "getAbilityList"=>proc{|pokemon|
    next [[getID(PBAbilities,:CLEARBODY),0]] if pokemon.form==1
    next
 },
 "height"=>proc{|pokemon|
    next 11 if pokemon.form==1
    next
 },
 "weight"=>proc{|pokemon|
    next 278 if pokemon.form==1
    next
 },
 "getUnmegaForm"=>proc{|pokemon|
   next 0
 }
 })
 
         MultipleForms.register(:RILLABOOM,{
 "getMegaForm"=>proc{|pokemon|
    next 1 if isConst?(pokemon.item,PBItems,:RILLABOOMITA)
    next
 },
 "getBaseStats"=>proc{|pokemon|
    next [120,140,100,90,65,90] if pokemon.form==1
    next
 },
 "getAbilityList"=>proc{|pokemon|
    next [[getID(PBAbilities,:GRASSPELT),0]] if pokemon.form==1
    next
 },
 "height"=>proc{|pokemon|
    next 11 if pokemon.form==1
    next
 },
 "weight"=>proc{|pokemon|
    next 278 if pokemon.form==1
    next
 },
 "getUnmegaForm"=>proc{|pokemon|
   next 0
 }
 })
 
         MultipleForms.register(:CINDERACE,{
 "getMegaForm"=>proc{|pokemon|
    next 1 if isConst?(pokemon.item,PBItems,:CINDERITA)
    next
 },
 "getBaseStats"=>proc{|pokemon|
    next [100,130,80,140,65,80] if pokemon.form==1
    next
 },
 "getAbilityList"=>proc{|pokemon|
    next [[getID(PBAbilities,:SPEEDBOOST),0]] if pokemon.form==1
    next
 },
 "height"=>proc{|pokemon|
    next 11 if pokemon.form==1
    next
 },
 "weight"=>proc{|pokemon|
    next 278 if pokemon.form==1
    next
 },
 "getUnmegaForm"=>proc{|pokemon|
   next 0
 }
 })
 
         MultipleForms.register(:INTELEON,{
 "getMegaForm"=>proc{|pokemon|
    next 1 if isConst?(pokemon.item,PBItems,:INTELITA)
    next
 },
 "getBaseStats"=>proc{|pokemon|
    next [90,80,75,140,155,75] if pokemon.form==1
    next
 },
 "getAbilityList"=>proc{|pokemon|
    next [[getID(PBAbilities,:SUPERLUCK),0]] if pokemon.form==1
    next
 },
 "height"=>proc{|pokemon|
    next 11 if pokemon.form==1
    next
 },
 "weight"=>proc{|pokemon|
    next 278 if pokemon.form==1
    next
 },
 "getUnmegaForm"=>proc{|pokemon|
   next 0
 }
 })
 
          MultipleForms.register(:CORVIKNIGHT,{
 "getMegaForm"=>proc{|pokemon|
    next 1 if isConst?(pokemon.item,PBItems,:CORVINITA)
    next
 },
 "getBaseStats"=>proc{|pokemon|
    next [130,100,120,80,60,100] if pokemon.form==1
    next
 },
 "getAbilityList"=>proc{|pokemon|
    next [[getID(PBAbilities,:FILTER),0]] if pokemon.form==1
    next
 },
 "height"=>proc{|pokemon|
    next 11 if pokemon.form==1
    next
 },
 "weight"=>proc{|pokemon|
    next 278 if pokemon.form==1
    next
 },
 "getUnmegaForm"=>proc{|pokemon|
   next 0
 }
 })
 
          MultipleForms.register(:ORBEETLE,{
 "getMegaForm"=>proc{|pokemon|
    next 1 if isConst?(pokemon.item,PBItems,:ORBEELITA)
    next
 },
 "getBaseStats"=>proc{|pokemon|
    next [100,50,135,110,120,135] if pokemon.form==1
    next
 },
 "getAbilityList"=>proc{|pokemon|
    next [[getID(PBAbilities,:NEUROFORCE),0]] if pokemon.form==1
    next
 },
 "height"=>proc{|pokemon|
    next 11 if pokemon.form==1
    next
 },
 "weight"=>proc{|pokemon|
    next 278 if pokemon.form==1
    next
 },
 "getUnmegaForm"=>proc{|pokemon|
   next 0
 }
 })
 
           MultipleForms.register(:MACHAMP,{
 "getMegaForm"=>proc{|pokemon|
    next 1 if isConst?(pokemon.item,PBItems,:MACHAMPITA)
    next
 },
 "getBaseStats"=>proc{|pokemon|
    next [100,150,90,85,30,90] if pokemon.form==1
    next
 },
 "getAbilityList"=>proc{|pokemon|
    next [[getID(PBAbilities,:NOGUARD),0]] if pokemon.form==1
    next
 },
 "height"=>proc{|pokemon|
    next 11 if pokemon.form==1
    next
 },
 "weight"=>proc{|pokemon|
    next 278 if pokemon.form==1
    next
 },
 "getUnmegaForm"=>proc{|pokemon|
   next 0
 }
 })
 
           MultipleForms.register(:SNORLAX,{
 "getMegaForm"=>proc{|pokemon|
    next 1 if isConst?(pokemon.item,PBItems,:SNORLITA)
    next
 },
 "getBaseStats"=>proc{|pokemon|
    next [200,130,125,10,75,125] if pokemon.form==1
    next
 },
 "getAbilityList"=>proc{|pokemon|
    next [[getID(PBAbilities,:GRASSYSURGE),0]] if pokemon.form==1
    next
 },
 "height"=>proc{|pokemon|
    next 11 if pokemon.form==1
    next
 },
 "weight"=>proc{|pokemon|
    next 278 if pokemon.form==1
    next
 },
 "getUnmegaForm"=>proc{|pokemon|
   next 0
 }
 })
 
            MultipleForms.register(:YANMEGA,{
 "getMegaForm"=>proc{|pokemon|
    next 1 if isConst?(pokemon.item,PBItems,:YANMITA)
    next
 },
 "getBaseStats"=>proc{|pokemon|
    next [110,20,100,160,180,100] if pokemon.form==1
    next
 },
 "type1"=>proc{|pokemon|
    next getID(PBTypes,:BUG) if pokemon.form==1
    next
 },
  "type2"=>proc{|pokemon|
    next getID(PBTypes,:DRAGON) if pokemon.form==1
    next
 },
 "getAbilityList"=>proc{|pokemon|
    next [[getID(PBAbilities,:TACTICAAH64),0]] if pokemon.form==1
    next
 },
 "height"=>proc{|pokemon|
    next 11 if pokemon.form==1
    next
 },
 "weight"=>proc{|pokemon|
    next 278 if pokemon.form==1
    next
 },
 "getUnmegaForm"=>proc{|pokemon|
   next 0
 }
 })

             MultipleForms.register(:STARMIE,{
 "getMegaForm"=>proc{|pokemon|
    next 1 if isConst?(pokemon.item,PBItems,:STARMITA)
    next
 },
 "getBaseStats"=>proc{|pokemon|
    next [60,100,105,120,130,105] if pokemon.form==1
    next
 },

 "getAbilityList"=>proc{|pokemon|
    next [[getID(PBAbilities,:HUGEPOWER),0]] if pokemon.form==1
    next
 },
 "height"=>proc{|pokemon|
    next 11 if pokemon.form==1
    next
 },
 "weight"=>proc{|pokemon|
    next 128 if pokemon.form==1
    next
 },
 "getUnmegaForm"=>proc{|pokemon|
   next 0
 }
 })
 
              MultipleForms.register(:MEGANIUM,{
 "getMegaForm"=>proc{|pokemon|
    next 1 if isConst?(pokemon.item,PBItems,:MEGANITA)
    next
 },
 "getBaseStats"=>proc{|pokemon|
    next [80,92,115,80,143,115] if pokemon.form==1
    next
 },
  "type2"=>proc{|pokemon|
    next getID(PBTypes,:FAIRY) if pokemon.form==1
    next
 },
 "getAbilityList"=>proc{|pokemon|
    next [[getID(PBAbilities,:TRIAGE),0]] if pokemon.form==1
    next
 },
 "height"=>proc{|pokemon|
    next 11 if pokemon.form==1
    next
 },
 "weight"=>proc{|pokemon|
    next 201 if pokemon.form==1
    next
 },
 "getUnmegaForm"=>proc{|pokemon|
   next 0
 }
 })
 
               MultipleForms.register(:MEW,{
 "getMegaForm"=>proc{|pokemon|
    next 1 if isConst?(pokemon.item,PBItems,:MEWITA)
    next
 },
 "getBaseStats"=>proc{|pokemon|
    next [100,50,110,180,160,110] if pokemon.form==1
    next
 },
  "type2"=>proc{|pokemon|
    next getID(PBTypes,:FIGHTING) if pokemon.form==1
    next
 },
 "getAbilityList"=>proc{|pokemon|
    next [[getID(PBAbilities,:SOULHEART),0]] if pokemon.form==1
    next
 },
 "height"=>proc{|pokemon|
    next 11 if pokemon.form==1
    next
 },
 "weight"=>proc{|pokemon|
    next 278 if pokemon.form==1
    next
 },
 "getUnmegaForm"=>proc{|pokemon|
   next 0
 }
 })
 
               MultipleForms.register(:DRAGONITE,{
 "getMegaForm"=>proc{|pokemon|
    next 1 if isConst?(pokemon.item,PBItems,:DRAGONITA)
    next
 },
 "getBaseStats"=>proc{|pokemon|
    next [100,170,120,140,100,120] if pokemon.form==1
    next
 },
  "type1"=>proc{|pokemon|
    next getID(PBTypes,:DRAGON) if pokemon.form==1
    next   
 },
  "type2"=>proc{|pokemon|
    next getID(PBTypes,:WATER) if pokemon.form==1
    next
 },
 "getAbilityList"=>proc{|pokemon|
    next [[getID(PBAbilities,:NOGUARD),0]] if pokemon.form==1
    next
 },
 "height"=>proc{|pokemon|
    next 11 if pokemon.form==1
    next
 },
 "weight"=>proc{|pokemon|
    next 290 if pokemon.form==1
    next
 },
 "getUnmegaForm"=>proc{|pokemon|
   next 0
 }
 })
 
                MultipleForms.register(:TORTERRA,{
 "getMegaForm"=>proc{|pokemon|
    next 1 if isConst?(pokemon.item,PBItems,:TORTERRITA)
    next
 },
 "getBaseStats"=>proc{|pokemon|
    next [110,145,135,75,55,105] if pokemon.form==1
    next
 },
  "type2"=>proc{|pokemon|
    next getID(PBTypes,:STEEL) if pokemon.form==1
    next
 },
 "getAbilityList"=>proc{|pokemon|
    next [[getID(PBAbilities,:SIMPLE),0]] if pokemon.form==1
    next
 },
 "height"=>proc{|pokemon|
    next 11 if pokemon.form==1
    next
 },
 "weight"=>proc{|pokemon|
    next 278 if pokemon.form==1
    next
 },
 "getUnmegaForm"=>proc{|pokemon|
   next 0
 }
 })
 
 MultipleForms.register(:STARAPTOR,{
 "getMegaForm"=>proc{|pokemon|
    next 1 if isConst?(pokemon.item,PBItems,:STARRAPTITA)
    next
 },
 "getBaseStats"=>proc{|pokemon|
    next [95,150,100,135,25,80] if pokemon.form==1
    next
 },
  "type2"=>proc{|pokemon|
    next getID(PBTypes,:FIGHTING) if pokemon.form==1
    next
 },
 "getAbilityList"=>proc{|pokemon|
    next [[getID(PBAbilities,:INTIMIDATE),0]] if pokemon.form==1
    next
 },
 "height"=>proc{|pokemon|
    next 11 if pokemon.form==1
    next
 },
 "weight"=>proc{|pokemon|
    next 278 if pokemon.form==1
    next
 },
 "getUnmegaForm"=>proc{|pokemon|
   next 0
 }
 })
 
  MultipleForms.register(:LUXRAY,{
 "getMegaForm"=>proc{|pokemon|
    next 1 if isConst?(pokemon.item,PBItems,:LUXRITA)
    next
 },
 "getBaseStats"=>proc{|pokemon|
    next [90,140,100,135,100,100] if pokemon.form==1
    next
 },
 "getAbilityList"=>proc{|pokemon|
    next [[getID(PBAbilities,:LEVITATE),0]] if pokemon.form==1
    next
 },
 "height"=>proc{|pokemon|
    next 11 if pokemon.form==1
    next
 },
 "weight"=>proc{|pokemon|
    next 278 if pokemon.form==1
    next
 },
 "getUnmegaForm"=>proc{|pokemon|
   next 0
 }
 })
 
   MultipleForms.register(:MELOETTA,{
 "getMegaForm"=>proc{|pokemon|
    next 2 if isConst?(pokemon.item,PBItems,:MELOTITA)
    next
 },
 "getMegaName"=>proc{|pokemon|
    next _INTL("Miku Meloetta") if pokemon.form==2
    next
 },
 "getBaseStats"=>proc{|pokemon|
    next [130,10,110,150,170,140] if pokemon.form==2
    next
 },
 "type1"=>proc{|pokemon|
    next getID(PBTypes,:FAIRY) if pokemon.form==2
    next 
 },   
 "type2"=>proc{|pokemon|
    next getID(PBTypes,:PSYCHIC) if pokemon.form==2
    next
 },
 "getAbilityList"=>proc{|pokemon|
    next [[getID(PBAbilities,:CUTECHARM),0]] if pokemon.form==2
    next
 },
 "height"=>proc{|pokemon|
    next 23 if pokemon.form==2
    next
 },
 "weight"=>proc{|pokemon|
    next 120 if pokemon.form==2
    next
 },
 "getUnmegaForm"=>proc{|pokemon|
   next 0
 }
 })
 
    MultipleForms.register(:SKARMORY,{
 "getMegaForm"=>proc{|pokemon|
    next 1 if isConst?(pokemon.item,PBItems,:SKARMITA)
    next
 },
 "getBaseStats"=>proc{|pokemon|
    next [65,180,130,150,40,120] if pokemon.form==1
    next
 },
 "getAbilityList"=>proc{|pokemon|
    next [[getID(PBAbilities,:SHARPNESS),0]] if pokemon.form==1
    next
 },
 "height"=>proc{|pokemon|
    next 11 if pokemon.form==1
    next
 },
 "weight"=>proc{|pokemon|
    next 278 if pokemon.form==1
    next
 },
 "getUnmegaForm"=>proc{|pokemon|
   next 0
 }
 })
 
    MultipleForms.register(:RAMPARDOS,{
 "getMegaForm"=>proc{|pokemon|
    next 1 if isConst?(pokemon.item,PBItems,:RAMPARDITA)
    next
 },
 "getBaseStats"=>proc{|pokemon|
    next [110,200,60,70,30,60] if pokemon.form==1
    next
 },
 "getAbilityList"=>proc{|pokemon|
    next [[getID(PBAbilities,:HUGEPOWER),0]] if pokemon.form==1
    next
 },
 "height"=>proc{|pokemon|
    next 11 if pokemon.form==1
    next
 },
 "weight"=>proc{|pokemon|
    next 278 if pokemon.form==1
    next
 },
 "getUnmegaForm"=>proc{|pokemon|
   next 0
 }
 })
 
    MultipleForms.register(:HAXORUS,{
 "getMegaForm"=>proc{|pokemon|
    next 1 if isConst?(pokemon.item,PBItems,:HAXORITA)
    next
 },
 "getMegaName"=>proc{|pokemon|
    next _INTL("Mega Haxorus") if pokemon.form==1
    next
 },
 "getBaseStats"=>proc{|pokemon|
    next [90,180,100,110,70,80] if pokemon.form==1
    next
 },   
 "type2"=>proc{|pokemon|
    next getID(PBTypes,:STEEL) if pokemon.form==1
    next
 },
 "getAbilityList"=>proc{|pokemon|
    next [[getID(PBAbilities,:TOUGHCLAWS),0]] if pokemon.form==1
    next
 },
 "height"=>proc{|pokemon|
    next 23 if pokemon.form==1
    next
 },
 "weight"=>proc{|pokemon|
    next 120 if pokemon.form==1
    next
 },
 "getUnmegaForm"=>proc{|pokemon|
   next 0
 }
 })
 
                 MultipleForms.register(:SERPERIOR,{
 "getMegaForm"=>proc{|pokemon|
    next 1 if isConst?(pokemon.item,PBItems,:SERPERITA)
    next
 },
 "getBaseStats"=>proc{|pokemon|
    next [95,75,95,160,145,115] if pokemon.form==1
    next
 },
  "type1"=>proc{|pokemon|
    next getID(PBTypes,:DRAGON) if pokemon.form==1
    next
 },
 "getAbilityList"=>proc{|pokemon|
    next [[getID(PBAbilities,:QUEENLYMAJESTY),0]] if pokemon.form==1
    next
 },
 "height"=>proc{|pokemon|
    next 11 if pokemon.form==1
    next
 },
 "weight"=>proc{|pokemon|
    next 278 if pokemon.form==1
    next
 },
 "getUnmegaForm"=>proc{|pokemon|
   next 0
 }
 })
 
                  MultipleForms.register(:MIENSHAO,{
 "getMegaForm"=>proc{|pokemon|
    next 1 if isConst?(pokemon.item,PBItems,:MIENSHITA)
    next
 },
 "getBaseStats"=>proc{|pokemon|
    next [95,165,100,145,95,65] if pokemon.form==1
    next
 },
 "getAbilityList"=>proc{|pokemon|
    next [[getID(PBAbilities,:TOUGHCLAWS),0]] if pokemon.form==1
    next
 },
 "height"=>proc{|pokemon|
    next 11 if pokemon.form==1
    next
 },
 "weight"=>proc{|pokemon|
    next 278 if pokemon.form==1
    next
 },
 "getUnmegaForm"=>proc{|pokemon|
   next 0
 }
 })
 
                   MultipleForms.register(:VOLCARONA,{
 "getMegaForm"=>proc{|pokemon|
    next 1 if isConst?(pokemon.item,PBItems,:VOLCARONITA)
    next
 },
 "getBaseStats"=>proc{|pokemon|
    next [125,60,70,110,175,135] if pokemon.form==1
    next
 },
 "getAbilityList"=>proc{|pokemon|
    next [[getID(PBAbilities,:SURCARROCAS),0]] if pokemon.form==1
    next
 },
 "height"=>proc{|pokemon|
    next 11 if pokemon.form==1
    next
 },
 "weight"=>proc{|pokemon|
    next 278 if pokemon.form==1
    next
 },
 "getUnmegaForm"=>proc{|pokemon|
   next 0
 }
 })
 
                    MultipleForms.register(:EXCADRILL,{
 "getMegaForm"=>proc{|pokemon|
    next 1 if isConst?(pokemon.item,PBItems,:EXCADRITA)
    next
 },
 "getBaseStats"=>proc{|pokemon|
    next [110,165,100,103,65,65] if pokemon.form==1
    next
 },
 "getAbilityList"=>proc{|pokemon|
    next [[getID(PBAbilities,:ARENATRAP),0]] if pokemon.form==1
    next
 },
 "height"=>proc{|pokemon|
    next 11 if pokemon.form==1
    next
 },
 "weight"=>proc{|pokemon|
    next 278 if pokemon.form==1
    next
 },
 "getUnmegaForm"=>proc{|pokemon|
   next 0
 }
 })
 
                     MultipleForms.register(:MILOTIC,{
 "getMegaForm"=>proc{|pokemon|
    next 1 if isConst?(pokemon.item,PBItems,:MILOTITA)
    next
 },
 "getBaseStats"=>proc{|pokemon|
    next [135,60,145,81,140,190] if pokemon.form==1
    next
 },
 "getAbilityList"=>proc{|pokemon|
    next [[getID(PBAbilities,:RAINDISH),0]] if pokemon.form==1
    next
 },
 "height"=>proc{|pokemon|
    next 11 if pokemon.form==1
    next
 },
 "weight"=>proc{|pokemon|
    next 278 if pokemon.form==1
    next
 },
 "getUnmegaForm"=>proc{|pokemon|
   next 0
 }
 })
 
                      MultipleForms.register(:FLORGES,{
 "getMegaForm"=>proc{|pokemon|
    next 5 if isConst?(pokemon.item,PBItems,:FLORGETITA)
    next
 },
 "getBaseStats"=>proc{|pokemon|
    next [108,65,68,75,130,180] if pokemon.form==5
    next
  },
  "type1"=>proc{|pokemon|
    next getID(PBTypes,:FAIRY) if pokemon.form==5
    next
  },
  "type2"=>proc{|pokemon|
    next getID(PBTypes,:WATER) if pokemon.form==5
    next
 },
 "getAbilityList"=>proc{|pokemon|
    next [[getID(PBAbilities,:LIQUIDVOICE),0]] if pokemon.form==5
    next
 },
 "height"=>proc{|pokemon|
    next 11 if pokemon.form==5
    next
 },
 "weight"=>proc{|pokemon|
    next 278 if pokemon.form==5
    next
 },
 "getUnmegaForm"=>proc{|pokemon|
   next 0
 }
 })
 
     MultipleForms.register(:MEOWTH,{
 "getMegaForm"=>proc{|pokemon|
    next 4 if isConst?(pokemon.item,PBItems,:MEOWTHITA)
    next
 },
 "getBaseStats"=>proc{|pokemon|
    next [80,90,70,180,80,80] if pokemon.form==4
    next
 },
 "getAbilityList"=>proc{|pokemon|
    next [[getID(PBAbilities,:INTIMIDATE),0]] if pokemon.form==4
    next
 },
 "height"=>proc{|pokemon|
    next 11 if pokemon.form==4
    next
 },
 "weight"=>proc{|pokemon|
    next 278 if pokemon.form==4
    next
 },
 "getUnmegaForm"=>proc{|pokemon|
   next 0
 }
 })
 
                      MultipleForms.register(:DREDNAW,{
 "getMegaForm"=>proc{|pokemon|
    next 1 if isConst?(pokemon.item,PBItems,:DREDNAWITA)
    next
 },
 "getBaseStats"=>proc{|pokemon|
    next [90,155,120,84,48,88] if pokemon.form==1
    next
 },
 "getAbilityList"=>proc{|pokemon|
    next [[getID(PBAbilities,:DRIZZLE),0]] if pokemon.form==1
    next
 },
 "height"=>proc{|pokemon|
    next 11 if pokemon.form==1
    next
 },
 "weight"=>proc{|pokemon|
    next 278 if pokemon.form==1
    next
 },
 "getUnmegaForm"=>proc{|pokemon|
   next 0
 }
 })
 
                       MultipleForms.register(:COALOSSAL,{
 "getMegaForm"=>proc{|pokemon|
    next 1 if isConst?(pokemon.item,PBItems,:COALOSSALITA)
    next
 },
 "getBaseStats"=>proc{|pokemon|
    next [110,100,120,30,80,130] if pokemon.form==1
    next
 },
 "getAbilityList"=>proc{|pokemon|
    next [[getID(PBAbilities,:EARTHEATER),0]] if pokemon.form==1
    next
 },
 "height"=>proc{|pokemon|
    next 11 if pokemon.form==1
    next
 },
 "weight"=>proc{|pokemon|
    next 278 if pokemon.form==1
    next
 },
 "getUnmegaForm"=>proc{|pokemon|
   next 0
 }
 })
 
                        MultipleForms.register(:FLAPPLE,{
 "getMegaForm"=>proc{|pokemon|
    next 1 if isConst?(pokemon.item,PBItems,:FLAPPLITA)
    next
 },
 "getBaseStats"=>proc{|pokemon|
    next [70,150,100,90,95,90] if pokemon.form==1
    next
 },
 "getAbilityList"=>proc{|pokemon|
    next [[getID(PBAbilities,:CONSERVACIONZERO),0]] if pokemon.form==1
    next
 },
 "height"=>proc{|pokemon|
    next 11 if pokemon.form==1
    next
 },
 "weight"=>proc{|pokemon|
    next 278 if pokemon.form==1
    next
 },
 "getUnmegaForm"=>proc{|pokemon|
   next 0
 }
 })
 
                         MultipleForms.register(:APPLETUN,{
 "getMegaForm"=>proc{|pokemon|
    next 1 if isConst?(pokemon.item,PBItems,:APPLETUNITA)
    next
 },
 "getBaseStats"=>proc{|pokemon|
    next [110,85,100,30,150,110] if pokemon.form==1
    next
 },
 "getAbilityList"=>proc{|pokemon|
    next [[getID(PBAbilities,:CONSERVACIONZERO),0]] if pokemon.form==1
    next
 },
 "height"=>proc{|pokemon|
    next 11 if pokemon.form==1
    next
 },
 "weight"=>proc{|pokemon|
    next 278 if pokemon.form==1
    next
 },
 "getUnmegaForm"=>proc{|pokemon|
   next 0
 }
 })
 
  MultipleForms.register(:SANDACONDA,{
 "getMegaForm"=>proc{|pokemon|
    next 1 if isConst?(pokemon.item,PBItems,:SANDACONDITA)
    next
 },
 "getBaseStats"=>proc{|pokemon|
    next [72,137,155,91,65,80] if pokemon.form==1
    next
 },
 "getAbilityList"=>proc{|pokemon|
    next [[getID(PBAbilities,:SANDVEIL),0]] if pokemon.form==1
    next
 },
 "height"=>proc{|pokemon|
    next 11 if pokemon.form==1
    next
 },
 "weight"=>proc{|pokemon|
    next 278 if pokemon.form==1
    next
 },
 "getUnmegaForm"=>proc{|pokemon|
   next 0
 }
 })

   MultipleForms.register(:HATTERENE,{
 "getMegaForm"=>proc{|pokemon|
    next 1 if isConst?(pokemon.item,PBItems,:HATTERENITA)
    next
 },
 "getBaseStats"=>proc{|pokemon|
    next [57,90,125,29,166,143] if pokemon.form==1
    next
 },
 "getAbilityList"=>proc{|pokemon|
    next [[getID(PBAbilities,:FILTER),0]] if pokemon.form==1
    next
 },
 "height"=>proc{|pokemon|
    next 11 if pokemon.form==1
    next
 },
 "weight"=>proc{|pokemon|
    next 278 if pokemon.form==1
    next
 },
 "getUnmegaForm"=>proc{|pokemon|
   next 0
 }
 })
 
     MultipleForms.register(:TOXTRICITY,{
 "getMegaForm"=>proc{|pokemon|
    next 2 if isConst?(pokemon.item,PBItems,:TOXTRITA)
    next
 },
 "getBaseStats"=>proc{|pokemon|
    next [75,98,90,105,134,100] if pokemon.form==2
    next
 },
 "getAbilityList"=>proc{|pokemon|
    next [[getID(PBAbilities,:LEVITATE),0]] if pokemon.form==2
    next
 },
 "height"=>proc{|pokemon|
    next 11 if pokemon.form==2
    next
 },
 "weight"=>proc{|pokemon|
    next 278 if pokemon.form==2
    next
 },
 "getUnmegaForm"=>proc{|pokemon|
   next 0
 }
 })
 
      MultipleForms.register(:CENTISKORCH,{
 "getMegaForm"=>proc{|pokemon|
    next 1 if isConst?(pokemon.item,PBItems,:CENTISKITA)
    next
 },
 "getBaseStats"=>proc{|pokemon|
    next [100,130,120,65,90,120] if pokemon.form==1
    next
 },
 "getAbilityList"=>proc{|pokemon|
    next [[getID(PBAbilities,:FURIAARTROPODO),0]] if pokemon.form==1
    next
 },
 "height"=>proc{|pokemon|
    next 11 if pokemon.form==1
    next
 },
 "weight"=>proc{|pokemon|
    next 278 if pokemon.form==1
    next
 },
 "getUnmegaForm"=>proc{|pokemon|
   next 0
 }
 })
 
       MultipleForms.register(:COPPERAJAH,{
 "getMegaForm"=>proc{|pokemon|
    next 1 if isConst?(pokemon.item,PBItems,:COPPERITA)
    next
 },
 "getBaseStats"=>proc{|pokemon|
    next [122,160,90,30,80,118] if pokemon.form==1
    next
 },
 "getAbilityList"=>proc{|pokemon|
    next [[getID(PBAbilities,:STAMINA),0]] if pokemon.form==1
    next
 },
 "height"=>proc{|pokemon|
    next 11 if pokemon.form==1
    next
 },
 "weight"=>proc{|pokemon|
    next 278 if pokemon.form==1
    next
 },
 "getUnmegaForm"=>proc{|pokemon|
   next 0
 }
 })
 
        MultipleForms.register(:DURALUDON,{
 "getMegaForm"=>proc{|pokemon|
    next 1 if isConst?(pokemon.item,PBItems,:DURALUDITA)
    next
 },
 "getBaseStats"=>proc{|pokemon|
    next [70,95,130,85,145,100] if pokemon.form==1
    next
 },
 "getAbilityList"=>proc{|pokemon|
    next [[getID(PBAbilities,:EARTHEATER),0]] if pokemon.form==1
    next
 },
 "height"=>proc{|pokemon|
    next 11 if pokemon.form==1
    next
 },
 "weight"=>proc{|pokemon|
    next 278 if pokemon.form==1
    next
 },
 "getUnmegaForm"=>proc{|pokemon|
   next 0
 }
 })
 
         MultipleForms.register(:GRIMMSNARL,{
 "getMegaForm"=>proc{|pokemon|
    next 1 if isConst?(pokemon.item,PBItems,:GRIMMSNARITA)
    next
 },
 "getBaseStats"=>proc{|pokemon|
    next [95,150,95,70,95,105] if pokemon.form==1
    next
 },
 "getAbilityList"=>proc{|pokemon|
    next [[getID(PBAbilities,:TERROR),0]] if pokemon.form==1
    next
 },
 "height"=>proc{|pokemon|
    next 11 if pokemon.form==1
    next
 },
 "weight"=>proc{|pokemon|
    next 278 if pokemon.form==1
    next
 },
 "getUnmegaForm"=>proc{|pokemon|
   next 0
 }
 })
 
          MultipleForms.register(:ALCREMIE,{
 "getMegaForm"=>proc{|pokemon|
    next 63 if isConst?(pokemon.item,PBItems,:ALCREMITA)
    next
 },
 "getBaseStats"=>proc{|pokemon|
    next [65,120,75,64,130,141] if pokemon.form==63
    next
 },
 "getAbilityList"=>proc{|pokemon|
    next [[getID(PBAbilities,:MURALLADOBLE),0]] if pokemon.form==63
    next
 },
 "height"=>proc{|pokemon|
    next 11 if pokemon.form==63
    next
 },
 "weight"=>proc{|pokemon|
    next 278 if pokemon.form==63
    next
 },
 "getUnmegaForm"=>proc{|pokemon|
   next 0
 }
 })
 
           MultipleForms.register(:URSHIFU,{
 "getMegaForm"=>proc{|pokemon|
    next 3 if isConst?(pokemon.item,PBItems,:URSHIFUITA)
    next
 },
 "getBaseStats"=>proc{|pokemon|
    next [100,200,110,97,63,80] if pokemon.form==3
    next
 },
 "getAbilityList"=>proc{|pokemon|
    next [[getID(PBAbilities,:UNSEENFIST),0]] if pokemon.form==3
    next
 },
 "height"=>proc{|pokemon|
    next 11 if pokemon.form==3
    next
 },
 "weight"=>proc{|pokemon|
    next 278 if pokemon.form==3
    next
 },
 "getUnmegaForm"=>proc{|pokemon|
   next 0
 }
 })
 
            MultipleForms.register(:URSHIFUAWA,{
 "getMegaForm"=>proc{|pokemon|
    next 2 if isConst?(pokemon.item,PBItems,:URSHIFUITA)
    next
 },
 "getBaseStats"=>proc{|pokemon|
    next [100,140,100,177,63,60] if pokemon.form==2
    next
 },
 "getAbilityList"=>proc{|pokemon|
    next [[getID(PBAbilities,:UNSEENFIST),0]] if pokemon.form==2
    next
 },
 "height"=>proc{|pokemon|
    next 11 if pokemon.form==2
    next
 },
 "weight"=>proc{|pokemon|
    next 278 if pokemon.form==2
    next
 },
 "getUnmegaForm"=>proc{|pokemon|
   next 0
 }
 })

             MultipleForms.register(:SHIFTRY,{
 "getMegaForm"=>proc{|pokemon|
    next 1 if isConst?(pokemon.item,PBItems,:SHIFTRYTA)
    next
 },
 "getBaseStats"=>proc{|pokemon|
    next [90,170,100,110,50,100] if pokemon.form==1
    next
 },
   "type1"=>proc{|pokemon|
    next getID(PBTypes,:FLYING) if pokemon.form==1
    next
 },
 "getAbilityList"=>proc{|pokemon|
    next [[getID(PBAbilities,:GALEWINGS),0]] if pokemon.form==1
    next
 },
 "height"=>proc{|pokemon|
    next 11 if pokemon.form==1
    next
 },
 "weight"=>proc{|pokemon|
    next 120 if pokemon.form==1
    next
 },
 "getUnmegaForm"=>proc{|pokemon|
   next 0
 }
 })
 
              MultipleForms.register(:ROSERADE,{
 "getMegaForm"=>proc{|pokemon|
    next 1 if isConst?(pokemon.item,PBItems,:ROSERADITA)
    next
 },
 "getBaseStats"=>proc{|pokemon|
    next [80,30,95,130,175,145] if pokemon.form==1
    next
 },
 "getAbilityList"=>proc{|pokemon|
    next [[getID(PBAbilities,:SERENEGRACE),0]] if pokemon.form==1
    next
 },
 "height"=>proc{|pokemon|
    next 11 if pokemon.form==1
    next
 },
 "weight"=>proc{|pokemon|
    next 120 if pokemon.form==1
    next
 },
 "getUnmegaForm"=>proc{|pokemon|
   next 0
 }
 })
 
               MultipleForms.register(:GRENINJA,{
 "getMegaForm"=>proc{|pokemon|
    next 2 if isConst?(pokemon.item,PBItems,:GRENINJITA)
    next
 },
 "getBaseStats"=>proc{|pokemon|
    next [72,125,77,142,133,81] if pokemon.form==2
    next
 },
 "getAbilityList"=>proc{|pokemon|
    next [[getID(PBAbilities,:PROTEAN),0]] if pokemon.form==2
    next
 },
 "height"=>proc{|pokemon|
    next 11 if pokemon.form==2
    next
 },
 "weight"=>proc{|pokemon|
    next 120 if pokemon.form==2
    next
 },
 "getUnmegaForm"=>proc{|pokemon|
   next 0
 }
 })
 
                MultipleForms.register(:DELPHOX,{
 "getMegaForm"=>proc{|pokemon|
    next 1 if isConst?(pokemon.item,PBItems,:DELPHOXITA)
    next
 },
 "getBaseStats"=>proc{|pokemon|
    next [75,69,72,134,159,125] if pokemon.form==1
    next
 },
 "getAbilityList"=>proc{|pokemon|
    next [[getID(PBAbilities,:LEVITATE),0]] if pokemon.form==1
    next
 },
 "height"=>proc{|pokemon|
    next 11 if pokemon.form==1
    next
 },
 "weight"=>proc{|pokemon|
    next 120 if pokemon.form==1
    next
 },
 "getUnmegaForm"=>proc{|pokemon|
   next 0
 }
 })
 
                 MultipleForms.register(:CHESNAUGHT,{
 "getMegaForm"=>proc{|pokemon|
    next 1 if isConst?(pokemon.item,PBItems,:CHESNAUGHTITA)
    next
 },
 "getBaseStats"=>proc{|pokemon|
    next [88,137,172,44,74,115] if pokemon.form==1
    next
 },
 "getAbilityList"=>proc{|pokemon|
    next [[getID(PBAbilities,:STAMINA),0]] if pokemon.form==1
    next
 },
 "height"=>proc{|pokemon|
    next 11 if pokemon.form==1
    next
 },
 "weight"=>proc{|pokemon|
    next 120 if pokemon.form==1
    next
 },
 "getUnmegaForm"=>proc{|pokemon|
   next 0
 }
 })
 
                   MultipleForms.register(:HAWLUCHA,{
 "getMegaForm"=>proc{|pokemon|
    next 1 if isConst?(pokemon.item,PBItems,:HAWLUCHITA)
    next
 },
 "getBaseStats"=>proc{|pokemon|
    next [78,137,100,118,74,93] if pokemon.form==1
    next
 },
 "getAbilityList"=>proc{|pokemon|
    next [[getID(PBAbilities,:HUSTLE),0]] if pokemon.form==1
    next
 },
 "height"=>proc{|pokemon|
    next 11 if pokemon.form==1
    next
 },
 "weight"=>proc{|pokemon|
    next 120 if pokemon.form==1
    next
 },
 "getUnmegaForm"=>proc{|pokemon|
   next 0
 }
 })
 
                   MultipleForms.register(:VICTREEBEL,{
 "getMegaForm"=>proc{|pokemon|
    next 1 if isConst?(pokemon.item,PBItems,:VICTREEBELITA)
    next
 },
 "getBaseStats"=>proc{|pokemon|
    next [80,125,85,70,135,95] if pokemon.form==1
    next
 },
 "getAbilityList"=>proc{|pokemon|
    next [[getID(PBAbilities,:LIQUIDOOZE),0]] if pokemon.form==1
    next
 },
 "height"=>proc{|pokemon|
    next 11 if pokemon.form==1
    next
 },
 "weight"=>proc{|pokemon|
    next 120 if pokemon.form==1
    next
 },
 "getUnmegaForm"=>proc{|pokemon|
   next 0
 }
 })
 
                    MultipleForms.register(:MALAMAR,{
 "getMegaForm"=>proc{|pokemon|
    next 1 if isConst?(pokemon.item,PBItems,:MALAMARITA)
    next
 },
 "getBaseStats"=>proc{|pokemon|
    next [86,122,108,88,58,120] if pokemon.form==1
    next
 },
 "getAbilityList"=>proc{|pokemon|
    next [[getID(PBAbilities,:PRANKSTER),0]] if pokemon.form==1
    next
 },
 "height"=>proc{|pokemon|
    next 11 if pokemon.form==1
    next
 },
 "weight"=>proc{|pokemon|
    next 120 if pokemon.form==1
    next
 },
 "getUnmegaForm"=>proc{|pokemon|
   next 0
 }
 })
 
                      MultipleForms.register(:ETERNATUS,{
 "getMegaForm"=>proc{|pokemon|
    next 1 if isConst?(pokemon.item,PBItems,:ETERNITA)
    next
 },
 "getBaseStats"=>proc{|pokemon|
    next [255,115,250,130,125,250] if pokemon.form==1
    next
 },
 "getAbilityList"=>proc{|pokemon|
    next [[getID(PBAbilities,:PRESSURE),0]] if pokemon.form==1
    next
 },
 "height"=>proc{|pokemon|
    next 11 if pokemon.form==1
    next
 },
 "weight"=>proc{|pokemon|
    next 950 if pokemon.form==1
    next
 },
 "getUnmegaForm"=>proc{|pokemon|
   next 0
 }
 })
 
                   MultipleForms.register(:DRAMPA,{
 "getMegaForm"=>proc{|pokemon|
    next 1 if isConst?(pokemon.item,PBItems,:DRAMPANITA)
    next
 },
 "getBaseStats"=>proc{|pokemon|
    next [78,85,110,36,160,116] if pokemon.form==1
    next
 },
 "getAbilityList"=>proc{|pokemon|
    next [[getID(PBAbilities,:LIGHTNINGROD),0]] if pokemon.form==1
    next
 },
 "height"=>proc{|pokemon|
    next 11 if pokemon.form==1
    next
 },
 "weight"=>proc{|pokemon|
    next 240 if pokemon.form==1
    next
 },
 "getUnmegaForm"=>proc{|pokemon|
   next 0
 }
 })
 
                    MultipleForms.register(:CLEFABLE,{
 "getMegaForm"=>proc{|pokemon|
    next 1 if isConst?(pokemon.item,PBItems,:CLEFABLITA)
    next
 },
 "getBaseStats"=>proc{|pokemon|
    next [95,80,93,70,135,110] if pokemon.form==1
    next
 },
 "getAbilityList"=>proc{|pokemon|
    next [[getID(PBAbilities,:AERILATE),0]] if pokemon.form==1
    next
 },
 "height"=>proc{|pokemon|
    next 11 if pokemon.form==1
    next
 },
 "weight"=>proc{|pokemon|
    next 120 if pokemon.form==1
    next
 },
 "getUnmegaForm"=>proc{|pokemon|
   next 0
 }
 })
 
MultipleForms.register(:ZYGARDE,{
"getMegaForm"=>proc{|pokemon|
   # Solo puede mega evolucionar si ya está en forma completa (forma 2)
   next 3 if pokemon.form==2 && isConst?(pokemon.item,PBItems,:ZYGARDITA)
   next
},
"getMegaName"=>proc{|pokemon|
   next _INTL("Mega Zygarde") if pokemon.form==3
   next
},
"getBaseStats"=>proc{|pokemon|
   next [216,70,91,100,216,85] if pokemon.form==3
   next
},
"getAbilityList"=>proc{|pokemon|
   next [[getID(PBAbilities,:NEUROFORCE),0]] if pokemon.form==3
   next
},
"height"=>proc{|pokemon|
   next 11 if pokemon.form==3
   next
},
"weight"=>proc{|pokemon|
   next 40 if pokemon.form==3
   next
},
"getUnmegaForm"=>proc{|pokemon|
   next 0 if pokemon.form==3
   next
}
})


MultipleForms.register(:RAICHU,{
  "getMegaForm"=>proc{|pokemon|
    next 3 if pokemon.form==0 && isConst?(pokemon.item,PBItems,:RAICHITA)  # ← IMPORTANTE: pokemon.form==0
    next 2 if pokemon.form==0 && isConst?(pokemon.item,PBItems,:RAICHITAY) # ← IMPORTANTE: pokemon.form==0
    next
  },
  
  "getMegaName"=>proc{|pokemon|
    next _INTL("Mega Raichu X") if pokemon.form==3
    next _INTL("Mega Raichu Y") if pokemon.form==2
    next
  },
  
  "getBaseStats"=>proc{|pokemon|
    next [60,135,90,120,90,80] if pokemon.form==3  # Mega Raichu X
    next [60,90,70,140,130,95] if pokemon.form==2  # Mega Raichu Y
    next
  },
  
  "type2"=>proc{|pokemon|
    next getID(PBTypes,:DARK) if pokemon.form==3    # Mega X: Eléctrico/Siniestro
    # Mega Y mantiene tipo puro Eléctrico (no especificamos nada)
    next
  },
  
  "getAbilityList"=>proc{|pokemon|
    next [[getID(PBAbilities,:IRONFIST),0]] if pokemon.form==3   # Mega Raichu X
    next [[getID(PBAbilities,:BERSERK),0]] if pokemon.form==2    # Mega Raichu Y
    next
  },
  
  "height"=>proc{|pokemon|
    next 11 if pokemon.form==3  # Mega Raichu X
    next 11 if pokemon.form==2  # Mega Raichu Y
    next
  },
  
  "weight"=>proc{|pokemon|
    next 40 if pokemon.form==3  # Mega Raichu X
    next 40 if pokemon.form==2  # Mega Raichu Y
    next
  },
  
  "getUnmegaForm"=>proc{|pokemon|
    next 0 if pokemon.form==3  # Mega X vuelve a forma 0
    next 0 if pokemon.form==2  # Mega Y vuelve a forma 0
    next
  }
})
 
 
                     MultipleForms.register(:FERALIGATR,{
 "getMegaForm"=>proc{|pokemon|
    next 1 if isConst?(pokemon.item,PBItems,:FERALIGATRITA)
    next
 },
 "getMegaName"=>proc{|pokemon|
    next _INTL("Mega Feraligatr") if pokemon.form==1
    next
 },
 "getBaseStats"=>proc{|pokemon|
    next [85,160,125,78,89,93] if pokemon.form==1
    next
 },
 "type2"=>proc{|pokemon|
    next getID(PBTypes,:DRAGON) if pokemon.form==1
    next
 },
 "getAbilityList"=>proc{|pokemon|
    next [[getID(PBAbilities,:STRONGJAW),0]] if pokemon.form==1
    next
 },
 "height"=>proc{|pokemon|
    next 11 if pokemon.form==1
    next
 },
 "weight"=>proc{|pokemon|
    next 120 if pokemon.form==1
    next
 },
 "getUnmegaForm"=>proc{|pokemon|
   next 0
 }
 })
 
 
                      MultipleForms.register(:FROSLASS,{
 "getMegaForm"=>proc{|pokemon|
    next 1 if isConst?(pokemon.item,PBItems,:FROSLASSITA)
    next
 },
 "getMegaName"=>proc{|pokemon|
    next _INTL("Mega Froslass") if pokemon.form==1
    next
 },
 "getBaseStats"=>proc{|pokemon|
    next [70,80,75,120,140,100] if pokemon.form==1
    next
 },
 "getAbilityList"=>proc{|pokemon|
    next [[getID(PBAbilities,:SNOWWARNING),0]] if pokemon.form==1
    next
 },
 "height"=>proc{|pokemon|
    next 11 if pokemon.form==1
    next
 },
 "weight"=>proc{|pokemon|
    next 120 if pokemon.form==1
    next
 },
 "getUnmegaForm"=>proc{|pokemon|
   next 0
 }
 })
 
                       MultipleForms.register(:EMBOAR,{
 "getMegaForm"=>proc{|pokemon|
    next 1 if isConst?(pokemon.item,PBItems,:EMBOARITA)
    next
 },
 "getMegaName"=>proc{|pokemon|
    next _INTL("Mega Emboar") if pokemon.form==1
    next
 },
 "getBaseStats"=>proc{|pokemon|
    next [110,148,75,75,110,110] if pokemon.form==1
    next
 },
 "getAbilityList"=>proc{|pokemon|
    next [[getID(PBAbilities,:MOXIE),0]] if pokemon.form==1
    next
 },
 "height"=>proc{|pokemon|
    next 11 if pokemon.form==1
    next
 },
 "weight"=>proc{|pokemon|
    next 120 if pokemon.form==1
    next
 },
 "getUnmegaForm"=>proc{|pokemon|
   next 0
 }
 })
 

                       MultipleForms.register(:SCOLIPEDE,{
 "getMegaForm"=>proc{|pokemon|
    next 1 if isConst?(pokemon.item,PBItems,:SCOLIPEDITA)
    next
 },
 "getMegaName"=>proc{|pokemon|
    next _INTL("Mega Scolipede") if pokemon.form==1
    next
 },
 "getBaseStats"=>proc{|pokemon|
    next [60,140,149,62,75,99] if pokemon.form==1
    next
 },
 "getAbilityList"=>proc{|pokemon|
    next [[getID(PBAbilities,:FILTER),0]] if pokemon.form==1
    next
 },
 "height"=>proc{|pokemon|
    next 11 if pokemon.form==1
    next
 },
 "weight"=>proc{|pokemon|
    next 120 if pokemon.form==1
    next
 },
 "getUnmegaForm"=>proc{|pokemon|
   next 0
 }
 })
 
                        MultipleForms.register(:SCRAFTY,{
 "getMegaForm"=>proc{|pokemon|
    next 1 if isConst?(pokemon.item,PBItems,:SCRAFTITA)
    next
 },
 "getMegaName"=>proc{|pokemon|
    next _INTL("Mega Scrafty") if pokemon.form==1
    next
 },
 "getBaseStats"=>proc{|pokemon|
    next [65,130,135,68,55,135] if pokemon.form==1
    next
 },
 "getAbilityList"=>proc{|pokemon|
    next [[getID(PBAbilities,:DARKAURA),0]] if pokemon.form==1
    next
 },
 "height"=>proc{|pokemon|
    next 11 if pokemon.form==1
    next
 },
 "weight"=>proc{|pokemon|
    next 120 if pokemon.form==1
    next
 },
 "getUnmegaForm"=>proc{|pokemon|
   next 0
 }
 })
 
                         MultipleForms.register(:EELEKTROSS,{
 "getMegaForm"=>proc{|pokemon|
    next 1 if isConst?(pokemon.item,PBItems,:EELEKTROSSITA)
    next
 },
 "getMegaName"=>proc{|pokemon|
    next _INTL("Mega Eelektross") if pokemon.form==1
    next
 },
 "getBaseStats"=>proc{|pokemon|
    next [85,145,80,80,135,90] if pokemon.form==1
    next
 },
 "getAbilityList"=>proc{|pokemon|
    next [[getID(PBAbilities,:LEVITATE),0]] if pokemon.form==1
    next
 },
 "height"=>proc{|pokemon|
    next 11 if pokemon.form==1
    next
 },
 "weight"=>proc{|pokemon|
    next 120 if pokemon.form==1
    next
 },
 "getUnmegaForm"=>proc{|pokemon|
   next 0
 }
 })
 
                          MultipleForms.register(:CHANDELURE,{
 "getMegaForm"=>proc{|pokemon|
    next 1 if isConst?(pokemon.item,PBItems,:CHANDELURITA)
    next
 },
 "getMegaName"=>proc{|pokemon|
    next _INTL("Mega Chandelure") if pokemon.form==1
    next
 },
 "getBaseStats"=>proc{|pokemon|
    next [60,75,110,90,175,110] if pokemon.form==1
    next
 },
 "getAbilityList"=>proc{|pokemon|
    next [[getID(PBAbilities,:LEVITATE),0]] if pokemon.form==1
    next
 },
 "height"=>proc{|pokemon|
    next 11 if pokemon.form==1
    next
 },
 "weight"=>proc{|pokemon|
    next 120 if pokemon.form==1
    next
 },
 "getUnmegaForm"=>proc{|pokemon|
   next 0
 }
 })
 
 
                          MultipleForms.register(:PYROAR,{
 "getMegaForm"=>proc{|pokemon|
    next 1 if isConst?(pokemon.item,PBItems,:PYROARITA)
    next
 },
 "getMegaName"=>proc{|pokemon|
    next _INTL("Mega Pyroar") if pokemon.form==1
    next
 },
 "getBaseStats"=>proc{|pokemon|
    next [86,88,92,126,129,86] if pokemon.form==1
    next
 },
 "getAbilityList"=>proc{|pokemon|
    next [[getID(PBAbilities,:FURCOAT),0]] if pokemon.form==1
    next
 },
 "height"=>proc{|pokemon|
    next 11 if pokemon.form==1
    next
 },
 "weight"=>proc{|pokemon|
    next 120 if pokemon.form==1
    next
 },
 "getUnmegaForm"=>proc{|pokemon|
   next 0
 }
 })
 

					MultipleForms.register(:FLOETTE,{
 "getMegaForm"=>proc{|pokemon|
    next 6 if pokemon.form==5 && isConst?(pokemon.item,PBItems,:FLOETTITA)
    next
 },
 "getMegaName"=>proc{|pokemon|
    next _INTL("Mega Floette Flor Eterna") if pokemon.form==6
    next
 },
 "getBaseStats"=>proc{|pokemon|
    next [74,85,87,102,155,148] if pokemon.form==6  # Ajusta las stats como quieras
    next
 },
 "getAbilityList"=>proc{|pokemon|
    next [[getID(PBAbilities,:SOULHEART),0]] if pokemon.form==6  # Cambia la habilidad si quieres
    next
 },
 "height"=>proc{|pokemon|
    next 11 if pokemon.form==6  # Ajusta la altura si quieres
    next
 },
 "weight"=>proc{|pokemon|
    next 40 if pokemon.form==6  # Ajusta el peso si quieres
    next
 },
 "getUnmegaForm"=>proc{|pokemon|
   next 5 if pokemon.form==6  # ← ESTO ES CRÍTICO
   next
 }
 })
 
 
                     MultipleForms.register(:BARBARACLE,{
 "getMegaForm"=>proc{|pokemon|
    next 1 if isConst?(pokemon.item,PBItems,:BARBARACLITA)
    next
 },
 "getMegaName"=>proc{|pokemon|
    next _INTL("Mega Barbaracle") if pokemon.form==1
    next
 },
 "getBaseStats"=>proc{|pokemon|
    next [72,140,130,88,64,106] if pokemon.form==1
    next
 },
 "type2"=>proc{|pokemon|
    next getID(PBTypes,:FIGHTING) if pokemon.form==1
    next
 },
 "getAbilityList"=>proc{|pokemon|
    next [[getID(PBAbilities,:SOLIDROCK),0]] if pokemon.form==1
    next
 },
 "height"=>proc{|pokemon|
    next 11 if pokemon.form==1
    next
 },
 "weight"=>proc{|pokemon|
    next 120 if pokemon.form==1
    next
 },
 "getUnmegaForm"=>proc{|pokemon|
   next 0
 }
 })
 
                      MultipleForms.register(:DRAGALGE,{
 "getMegaForm"=>proc{|pokemon|
    next 1 if isConst?(pokemon.item,PBItems,:DRAGALGITA)
    next
 },
 "getMegaName"=>proc{|pokemon|
    next _INTL("Mega Dragalge") if pokemon.form==1
    next
 },
 "getBaseStats"=>proc{|pokemon|
    next [65,80,105,44,132,163] if pokemon.form==1
    next
 },
 "getAbilityList"=>proc{|pokemon|
    next [[getID(PBAbilities,:TOXICDEBRIS),0]] if pokemon.form==1
    next
 },
 "height"=>proc{|pokemon|
    next 11 if pokemon.form==1
    next
 },
 "weight"=>proc{|pokemon|
    next 120 if pokemon.form==1
    next
 },
 "getUnmegaForm"=>proc{|pokemon|
   next 0
 }
 })
 

                        MultipleForms.register(:FALINKS,{
 "getMegaForm"=>proc{|pokemon|
    next 1 if isConst?(pokemon.item,PBItems,:FALINKSITA)
    next
 },
 "getMegaName"=>proc{|pokemon|
    next _INTL("Mega Falinks") if pokemon.form==1
    next
 },
 "getBaseStats"=>proc{|pokemon|
    next [65,135,135,100,70,65] if pokemon.form==1
    next
 },
 "getAbilityList"=>proc{|pokemon|
    next [[getID(PBAbilities,:GUTS),0]] if pokemon.form==1
    next
 },
 "height"=>proc{|pokemon|
    next 11 if pokemon.form==1
    next
 },
 "weight"=>proc{|pokemon|
    next 120 if pokemon.form==1
    next
 },
 "getUnmegaForm"=>proc{|pokemon|
   next 0
 }
 })
 
 
                        MultipleForms.register(:BAXCALIBUR,{
 "getMegaForm"=>proc{|pokemon|
    next 1 if isConst?(pokemon.item,PBItems,:BAXCALIBURITA)
    next
 },
 "getMegaName"=>proc{|pokemon|
    next _INTL("Mega Baxcalibur") if pokemon.form==1
    next
 },
 "getBaseStats"=>proc{|pokemon|
    next [115,180,112,110,77,96] if pokemon.form==1
    next
 },
 "getAbilityList"=>proc{|pokemon|
    next [[getID(PBAbilities,:INTREPIDSWORD),0]] if pokemon.form==1
    next
 },
 "height"=>proc{|pokemon|
    next 11 if pokemon.form==1
    next
 },
 "weight"=>proc{|pokemon|
    next 120 if pokemon.form==1
    next
 },
 "getUnmegaForm"=>proc{|pokemon|
   next 0
 }
 })
 
 
                      MultipleForms.register(:CHIMECHO,{
 "getMegaForm"=>proc{|pokemon|
    next 1 if isConst?(pokemon.item,PBItems,:CHIMECHITA)
    next
 },
 "getMegaName"=>proc{|pokemon|
    next _INTL("Mega Chimecho") if pokemon.form==1
    next
 },
 "getBaseStats"=>proc{|pokemon|
    next [75,50,110,85,125,110] if pokemon.form==1
    next
 },
 "type2"=>proc{|pokemon|
    next getID(PBTypes,:STEEL) if pokemon.form==1
    next
 },
 "getAbilityList"=>proc{|pokemon|
    next [[getID(PBAbilities,:MAGICBOUNCE),0]] if pokemon.form==1
    next
 },
 "height"=>proc{|pokemon|
    next 11 if pokemon.form==1
    next
 },
 "weight"=>proc{|pokemon|
    next 120 if pokemon.form==1
    next
 },
 "getUnmegaForm"=>proc{|pokemon|
   next 0
 }
 })
 
 MultipleForms.register(:MAGEARNA,{
"getMegaForm"=>proc{|pokemon|
   next 2 if pokemon.form==0 && isConst?(pokemon.item,PBItems,:MAGEARNITA)  # Magearna normal → Mega forma 2
   next 3 if pokemon.form==1 && isConst?(pokemon.item,PBItems,:MAGEARNITA)  # Magearna Vetusta → Mega forma 3
   next
},
"getMegaName"=>proc{|pokemon|
   next _INTL("Mega Magearna") if pokemon.form==2
   next _INTL("Mega Magearna Vetusta") if pokemon.form==3
   next
},
"getBaseStats"=>proc{|pokemon|
   next [80,125,115,95,170,115] if pokemon.form==2  # Mega Magearna
   next [80,125,115,95,170,115] if pokemon.form==3  # Mega Magearna Vetusta (mismas stats)
   next
},
"getAbilityList"=>proc{|pokemon|
   next [[getID(PBAbilities,:SOULHEART),0]] if pokemon.form==2
   next [[getID(PBAbilities,:SOULHEART),0]] if pokemon.form==3
   next
},
"height"=>proc{|pokemon|
   next 10 if pokemon.form==2
   next 10 if pokemon.form==3
   next
},
"weight"=>proc{|pokemon|
   next 805 if pokemon.form==2
   next 805 if pokemon.form==3
   next
},
"getUnmegaForm"=>proc{|pokemon|
   next 0 if pokemon.form==2  # Mega Magearna vuelve a forma 0
   next 1 if pokemon.form==3  # Mega Magearna Vetusta vuelve a forma 1
   next
}
})

MultipleForms.register(:TATSUGIRI,{
"getMegaForm"=>proc{|pokemon|
   next 3 if pokemon.form==0 && isConst?(pokemon.item,PBItems,:TATSUGIRITA)  # Tatsugiri Curly (0) → Mega forma 3
   next 4 if pokemon.form==1 && isConst?(pokemon.item,PBItems,:TATSUGIRITA)  # Tatsugiri Droopy (1) → Mega forma 4
   next 5 if pokemon.form==2 && isConst?(pokemon.item,PBItems,:TATSUGIRITA)  # Tatsugiri Stretchy (2) → Mega forma 5
   next
},
"getMegaName"=>proc{|pokemon|
   next _INTL("Mega Tatsugiri") if pokemon.form==3
   next _INTL("Mega Tatsugiri") if pokemon.form==4
   next _INTL("Mega Tatsugiri") if pokemon.form==5
   next
},
"getBaseStats"=>proc{|pokemon|
   next [68,65,90,92,135,125] if pokemon.form==3  # Mega Tatsugiri Curly
   next [68,65,90,92,135,125] if pokemon.form==4  # Mega Tatsugiri Droopy
   next [68,65,90,92,135,125] if pokemon.form==5  # Mega Tatsugiri Stretchy
   next
},
"getAbilityList"=>proc{|pokemon|
   next [[getID(PBAbilities,:NOGUARD),0]] if pokemon.form==3
   next [[getID(PBAbilities,:NOGUARD),0]] if pokemon.form==4
   next [[getID(PBAbilities,:NOGUARD),0]] if pokemon.form==5
   next
},
"height"=>proc{|pokemon|
   next 3 if pokemon.form==3
   next 3 if pokemon.form==4
   next 3 if pokemon.form==5
   next
},
"weight"=>proc{|pokemon|
   next 80 if pokemon.form==3
   next 80 if pokemon.form==4
   next 80 if pokemon.form==5
   next
},
"getUnmegaForm"=>proc{|pokemon|
   next 0 if pokemon.form==3  # Mega Curly → vuelve a forma 0 (Curly)
   next 1 if pokemon.form==4  # Mega Droopy → vuelve a forma 1 (Droopy)
   next 2 if pokemon.form==5  # Mega Stretchy → vuelve a forma 2 (Stretchy)
   next
}
})

MultipleForms.register(:GOLISOPOD,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:GOLISOPODITA)
   next
},
"getMegaName"=>proc{|pokemon|
   next _INTL("Mega Golisopod") if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next [75,150,175,40,70,120] if pokemon.form==1
   next
},
"type2"=>proc{|pokemon|
   next getID(PBTypes,:STEEL) if pokemon.form==1  # Bug/Steel
   next
},
"getAbilityList"=>proc{|pokemon|
   next [[getID(PBAbilities,:HEATPROOF),0]] if pokemon.form==1
   next
},
"height"=>proc{|pokemon|
   next 20 if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 1080 if pokemon.form==1
   next
},
"getUnmegaForm"=>proc{|pokemon|
   next 0
}
})

 MultipleForms.register(:HEATRAN,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:HEATRANITA)
   next
},
"getMegaName"=>proc{|pokemon|
   next _INTL("Mega Heatran") if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next [91,120,106,67,175,141] if pokemon.form==1
   next
},
"getAbilityList"=>proc{|pokemon|
   next [[getID(PBAbilities,:EARTHEATER),0]] if pokemon.form==1
   next
},
"height"=>proc{|pokemon|
   next 4.7 if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 730.0 if pokemon.form==1
   next
},
"getUnmegaForm"=>proc{|pokemon|
   next 0
}
})

MultipleForms.register(:DARKRAI,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:DARKRAINITA)
   next
},
"getMegaName"=>proc{|pokemon|
   next _INTL("Mega Darkrai") if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next [70,120,140,65,165,140] if pokemon.form==1
   next
},
"getAbilityList"=>proc{|pokemon|
   next [[getID(PBAbilities,:ATEMORIZAR),0]] if pokemon.form==1
   next
},
"height"=>proc{|pokemon|
   next 3.0 if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 240.5 if pokemon.form==1
   next
},
"getUnmegaForm"=>proc{|pokemon|
   next 0
}
})

MultipleForms.register(:GOLURK,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:GOLURKITA)
   next
},
"getMegaName"=>proc{|pokemon|
   next _INTL("Mega Golurk") if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next [89,159,105,55,70,105] if pokemon.form==1
   next
},
"getAbilityList"=>proc{|pokemon|
   next [[getID(PBAbilities,:SOLIDROCK),0]] if pokemon.form==1
   next
},
"height"=>proc{|pokemon|
   next 2.8 if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 330.0 if pokemon.form==1
   next
},
"getUnmegaForm"=>proc{|pokemon|
   next 0
}
})

MultipleForms.register(:MEOWSTIC,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:MEOWSTICITA)
   next
},
"getMegaName"=>proc{|pokemon|
   next _INTL("Mega Meowstic") if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next [74,48,76,124,143,101] if pokemon.form==1
   next
},
"getAbilityList"=>proc{|pokemon|
   next [[getID(PBAbilities,:PSYCHICSURGE),0]] if pokemon.form==1
   next
},
"height"=>proc{|pokemon|
   next 0.8 if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 10.1 if pokemon.form==1
   next
},
"getUnmegaForm"=>proc{|pokemon|
   next 0
}
})

MultipleForms.register(:CRABOMINABLE,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:CRABOMINABLITA)
   next
},
"getMegaName"=>proc{|pokemon|
   next _INTL("Mega Crabominable") if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next [97,157,122,33,62,107] if pokemon.form==1
   next
},
"getAbilityList"=>proc{|pokemon|
   next [[getID(PBAbilities,:CUSPIDEMENTAL),0]] if pokemon.form==1
   next
},
"height"=>proc{|pokemon|
   next 2.6 if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 252.8 if pokemon.form==1
   next
},
"getUnmegaForm"=>proc{|pokemon|
   next 0
}
})

MultipleForms.register(:ZERAORA,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:ZERAORANITA)
   next
},
"getMegaName"=>proc{|pokemon|
   next _INTL("Mega Zeraora") if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next [88,157,75,153,147,80] if pokemon.form==1
   next
},
"getAbilityList"=>proc{|pokemon|
   next [[getID(PBAbilities,:SUPERLUCK),0]] if pokemon.form==1
   next
},
"height"=>proc{|pokemon|
   next 1.5 if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 44.5 if pokemon.form==1
   next
},
"getUnmegaForm"=>proc{|pokemon|
   next 0
}
})

MultipleForms.register(:SCOVILLAIN,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:SCOVILLAINITA)
   next
},
"getMegaName"=>proc{|pokemon|
   next _INTL("Mega Scovillain") if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next [65,138,85,75,138,85] if pokemon.form==1
   next
},
"getAbilityList"=>proc{|pokemon|
   next [[getID(PBAbilities,:OPPORTUNIST),0]] if pokemon.form==1
   next
},
"height"=>proc{|pokemon|
   next 1.2 if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 22.0 if pokemon.form==1
   next
},
"getUnmegaForm"=>proc{|pokemon|
   next 0
}
})

MultipleForms.register(:GLIMMORA,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:GLIMMORANITA)
   next
},
"getMegaName"=>proc{|pokemon|
   next _INTL("Mega Glimmora") if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next [83,90,105,101,150,96] if pokemon.form==1
   next
},
"getAbilityList"=>proc{|pokemon|
   next [[getID(PBAbilities,:SANGUICORROSION),0]] if pokemon.form==1
   next
},
"height"=>proc{|pokemon|
   next 2.8 if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 77.0 if pokemon.form==1
   next
},
"getUnmegaForm"=>proc{|pokemon|
   next 0
}
})

MultipleForms.register(:JUMPLUFF,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:JUMPLUFFITA)
   next
},
"getMegaName"=>proc{|pokemon|
   next _INTL("Mega Jumpluff") if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next [75,115,120,140,55,105] if pokemon.form==1
   next
},
"getAbilityList"=>proc{|pokemon|
   next [[getID(PBAbilities,:SPEEDBOOST),0]] if pokemon.form==1
   next
},
"height"=>proc{|pokemon|
   next 0.8 if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 3.0 if pokemon.form==1
   next
},
"getUnmegaForm"=>proc{|pokemon|
   next 0
}
})
 ################################################################################
 ######################### Regresión Primigenia #################################
 ################################################################################

 MultipleForms.register(:KYOGRE,{
 "getPrimalForm"=>proc{|pokemon|
    next 1 if isConst?(pokemon.item,PBItems,:BLUEORB)
    next
 },
 "getBaseStats"=>proc{|pokemon|
    next [100,150,90,90,180,160] if pokemon.form==1
    next
 },
 "getAbilityList"=>proc{|pokemon|
    next [[getID(PBAbilities,:PRIMORDIALSEA),0]] if pokemon.form==1
    next
 },
 "height"=>proc{|pokemon|
    next 98 if pokemon.form==1
    next
 },
 "weight"=>proc{|pokemon|
    next 4300 if pokemon.form==1
    next
 },
 "getUnprimalForm"=>proc{|pokemon|
   next 0
 }
 })

 MultipleForms.register(:GROUDON,{
 "getPrimalForm"=>proc{|pokemon|
    next 1 if isConst?(pokemon.item,PBItems,:REDORB)
    next
 },
 "getBaseStats"=>proc{|pokemon|
    next [100,180,160,90,150,90] if pokemon.form==1
    next
 },
 "type2"=>proc{|pokemon|
    next getID(PBTypes,:FIRE) if pokemon.form==1
    next
 },
 "getAbilityList"=>proc{|pokemon|
    next [[getID(PBAbilities,:DESOLATELAND),0]] if pokemon.form==1
    next
 },
 "height"=>proc{|pokemon|
    next 50 if pokemon.form==1
    next
 },
 "weight"=>proc{|pokemon|
    next 9997 if pokemon.form==1
    next
 },
 "getUnprimalForm"=>proc{|pokemon|
   next 0
 }
 })

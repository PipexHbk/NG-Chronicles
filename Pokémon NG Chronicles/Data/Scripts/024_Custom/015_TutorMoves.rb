#True si quieres mostrar los movimientos huevo
SHOWEGGMOVES=true
#Nivel mínimo del Pokémon para mostrar los movimientos huevo
EGGLEVEL=10
#True si quieres mostrar los movimientos de tutor
SHOWTUTORMOVES=true
#Nivel mínimo del Pokémon para mostrar los movimientos de tutor
TUTORLEVEL=15
#True si quieres mostrar los movimientos de MT
SHOWMACHINEMOVES=true
#Nivel mínimo del Pokémon para mostrar los movimientos de MT
MACHINELEVEL=10
#True si quieres que pueda recordarse cualquier movimiento por nivel
#como en el recuerdamovimientos de Sol y Luna
SLOPTION=false
#False si quieres mostrar solo las MT's que tiene el jugador
ALLMTS=false
def pbGetRelearnableMoves(pokemon, showeggmove=SHOWEGGMOVES, egglevel=EGGLEVEL,
  showtutormoves=SHOWTUTORMOVES, tutorlevel=TUTORLEVEL, showmachinemoves=SHOWMACHINEMOVES,
  machinelevel=MACHINELEVEL, sloption=SLOPTION, allmts=ALLMTS)
  
  return [] if !pokemon || pokemon.isEgg? || (pokemon.isShadow? rescue false)
  moves=[]
  pbEachNaturalMove(pokemon){|move,level|
     if (level<=pokemon.level || sloption) && !pokemon.hasMove?(move)
       moves.push(move) if !moves.include?(move)
     end
  }
  tmoves=[]
  if pokemon.firstmoves
    for i in pokemon.firstmoves
      tmoves.push(i) if !pokemon.hasMove?(i) && !moves.include?(i)
    end
  end
  
  eggMoves=[]
  if showeggmove && egglevel <= pokemon.level
    species=getID(PBSpecies,pokemon.species)
    babyspecies=pbGetBabySpecies(species,0,0)
    pbRgssOpen("Data/eggEmerald.dat","rb"){|f|
      f.pos=(babyspecies-1)*8
      offset=f.fgetdw
      length=f.fgetdw
      if length>0
        f.pos=offset
        i=0; loop do break unless i<length
          atk=f.fgetw
          eggMoves.push(atk) if !pokemon.hasMove?(atk) && !moves.include?(atk) && 
          !tmoves.include?(atk) && !eggMoves.include?(atk)
          i+=1
        end
      end
      }
    end
 
    tutorMoves=[]
    machineMoves=[]
    tmData=load_data("Data/tm.dat")
    for move in 1...tmData.size
      next if !tmData[move]
      if tmData[move].any?{ |item| item==pokemon.species }
        tutorMoves.push(move) if !pokemon.hasMove?(move) && !moves.include?(move) && 
        !tmoves.include?(move) && !eggMoves.include?(move) && !tutorMoves.include?(move)
      end
    end
      
    for item in 1..PBItems.maxValue
      if pbIsMachine?(item)
        move = $ItemData[item][ITEMMACHINE]
        if tutorMoves.include?(move)
          tutorMoves.delete(move)
          if !pokemon.hasMove?(move) && !moves.include?(move) && !tmoves.include?(move) &&
            !eggMoves.include?(move) && !tutorMoves.include?(move)
            machineMoves.push(move) if $PokemonBag.pbQuantity(item)>0 || allmts
          end
        end
      end
    end
    
    machineMoves=[] if !showmachinemoves || machinelevel > pokemon.level
    tutorMoves=[] if !showtutormoves || tutorlevel > pokemon.level
    
  moves=tmoves+moves+eggMoves+tutorMoves+machineMoves
  return moves|[] # remove duplicates
end
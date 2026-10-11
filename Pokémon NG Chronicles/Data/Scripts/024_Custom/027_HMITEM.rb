#==============================================================================#
#                                    HM Items                                  #
#                                    by Marin                                  #
#==============================================================================#
#                       No coding knowledge required at all.                    #
#                                                                              #
#  Because the items override the actual moves' functionality, the items have  #
#      switches to toggle them, as you see below (USING_SURF_ITEM, etc.)       #
#   If they're set to true, the items will be active and will override some    #
#                 in-field functionality of the moves themselves.              #
#==============================================================================#
#      Rock Smash, Strength and Cut all use the default Essentials events.     #
#==============================================================================#
#                    Please give credit when using this.                       #
#==============================================================================#

# Future updates may contain: Flash, Headbutt, Sweet Scent, Rock Climb.


# The internal name of the item that will trigger Surf
SURF_ITEM = :SURFWHISTLE

# The internal name of the item that will trigger Rock Smash
ROCK_SMASH_ITEM = :SLEDGEHAMMER

# The internal name of the item that will trigger Fly
FLY_ITEM = :FLYWHISTLE

# The internal name of the item that will trigger Strength
STRENGTH_ITEM = :STRENGTHGAUNTLET

# The internal name of the item that will trigger Cut
CUT_ITEM = :AXE

# The internal name of the item that will trigger Headbutt
HEADBUTT_ITEM = :ARBORIETE



# When true, this overrides the old surfing mechanics.
USING_SURF_ITEM = true

# When true, this overrides the old rock smash mechanics.
USING_ROCK_SMASH_ITEM = true

# When true, this overrides the old fly mechanics.
USING_FLY_ITEM = true

# When true, this overrides the old strength mechanics.
USING_STRENGTH_ITEM = true

# When true, this overrides the old cut mechanics.
USING_CUT_ITEM = true

# When true, this overrides the old headbutt mechanics with ARBORIETE.
USING_HEADBUTT_ITEM = true

#==============================================================================#
# This section of code contains minor utility methods.                         #
#==============================================================================#

class Game_Map
  attr_reader :map
end

class Game_Player
  attr_writer :x
  attr_writer :y
end

class HandlerHash
  def delete(sym)
    id = fromSymbol(sym)
    @hash.delete(id) if id && @hash[id]
    symbol = toSymbol(sym)
    @hash.delete(symbol) if symbol && @hash[symbol]
  end
end

# Manejo del estado del ARBORIETE
class PokemonGlobal
  attr_accessor :arboriete_mode
  
  def initialize
    super
    @arboriete_mode = 0  # 0 = Suave (HeadbuttLow), 1 = Fuerte (HeadbuttHigh)
  end
end

def pbSmashEvent(event)
  return unless event
  if event.name == "Tree"
    pbSEPlay("Cut", 80)
  elsif event.name == "Rock"
    pbSEPlay("Rock Smash", 80)
  end
  pbMoveRoute(event,[
     PBMoveRoute::TurnDown,
     PBMoveRoute::Wait, 2,
     PBMoveRoute::TurnLeft,
     PBMoveRoute::Wait, 2,
     PBMoveRoute::TurnRight,
     PBMoveRoute::Wait, 2,
     PBMoveRoute::TurnUp,
     PBMoveRoute::Wait, 2
  ])
  pbWait(16)
  event.erase
  $PokemonMap.addErasedEvent(event.id) if $PokemonMap
end


#==============================================================================#
# This section of the code handles the item that calls Surf.                   #
#==============================================================================#

if USING_SURF_ITEM
  HiddenMoveHandlers::CanUseMove.delete(:SURF)
  HiddenMoveHandlers::UseMove.delete(:SURF)
  
  def Kernel.pbSurf
    return false if $game_player.pbHasDependentEvents?
    move = getID(PBMoves,:SURF)
    if !$Trainer.badges[10] && !$DEBUG
      return false
    end
    if Kernel.pbConfirmMessage(_INTL("El agua de aquí parece navegable...\n¿Te gustaría llamar a la montura de surfeo?"))
      Kernel.pbMessage(_INTL("¡{1} utilizó el {2}!", $Trainer.name, PBItems.getName(getConst(PBItems,SURF_ITEM))))
      Kernel.pbCancelVehicles
      surfbgm = pbGetMetadata(0,MetadataSurfBGM)
      pbCueBGM(surfbgm,0.5) if surfbgm
      pbStartSurfing
      return true
    end
    return false
  end
  
  ItemHandlers::UseInField.add(:SURFWHISTLE, proc do |item|
    $game_temp.in_menu = false
    Kernel.pbSurf
    return true
  end)
  
  ItemHandlers::UseFromBag.add(:SURFWHISTLE, proc do |item|
    return false if $PokemonGlobal.surfing ||
                    pbGetMetadata($game_map.map_id,MetadataBicycleAlways) ||
                    !PBTerrain.isSurfable?(Kernel.pbFacingTerrainTag) ||
                    !$game_map.passable?($game_player.x,$game_player.y,$game_player.direction,$game_player)
    return 2
  end)
end

#==============================================================================#
# This section of the code handles the item that calls Fly.                    #
#==============================================================================#

if USING_FLY_ITEM
  ItemHandlers::UseFromBag.add(:FLYWHISTLE, proc do |item|
    $game_temp.in_menu = false
    # Primero verificar que estamos en exterior
    return false unless pbGetMetadata($game_map.map_id,MetadataOutdoor)
    
    # Abrir el mapa de vuelo
    if defined?(BetterRegionMap)
      ret = pbBetterRegionMap(nil, true, true)
    else
      ret = pbFadeOutIn(99999) do
        pbSEPlay("FlautaEon")
        scene = PokemonRegionMap_Scene.new(-1, false)
        screen = PokemonRegionMapScreen.new(scene)
        next screen.pbStartFlyScreen
      end
    end
    
    # Si se seleccionó un destino, viajar
    if ret
      $PokemonTemp.flydata = ret  # Guardar el destino
      return 2
    end
    return 0
  end)
  
  ItemHandlers::UseInField.add(:FLYWHISTLE, proc do |item|
    $game_temp.in_menu = false
    
    # Si ya tenemos datos de vuelo guardados (viene de la mochila), usarlos
    if $PokemonTemp.flydata
      Kernel.pbMessage(_INTL("¡{1} usó su {2}!", $Trainer.name, PBItems.getName(getConst(PBItems,:FLYWHISTLE))))
      pbFadeOutIn(99999) do
         $game_temp.player_new_map_id    = $PokemonTemp.flydata[0]
         $game_temp.player_new_x         = $PokemonTemp.flydata[1]
         $game_temp.player_new_y         = $PokemonTemp.flydata[2]
         $game_temp.player_new_direction = 2
         Kernel.pbCancelVehicles
         $PokemonTemp.flydata = nil
         $scene.transfer_player
         $game_map.autoplay
         $game_map.refresh
      end
      pbEraseEscapePoint
      return true
    end
    
    # Si no hay datos, abrir el mapa de vuelo (viene del acceso directo)
    return false unless pbGetMetadata($game_map.map_id,MetadataOutdoor)
    
    if defined?(BetterRegionMap)
      ret = pbBetterRegionMap(nil, true, true)
    else
      ret = pbFadeOutIn(99999) do
        pbSEPlay("FlautaEon")
        scene = PokemonRegionMap_Scene.new(-1, false)
        screen = PokemonRegionMapScreen.new(scene)
        next screen.pbStartFlyScreen
      end
    end
    
    if ret
      Kernel.pbMessage(_INTL("¡{1} usó su {2}!", $Trainer.name, PBItems.getName(getConst(PBItems,:FLYWHISTLE))))
      pbFadeOutIn(99999) do
         $game_temp.player_new_map_id    = ret[0]
         $game_temp.player_new_x         = ret[1]
         $game_temp.player_new_y         = ret[2]
         $game_temp.player_new_direction = 2
         Kernel.pbCancelVehicles
         $scene.transfer_player
         $game_map.autoplay
         $game_map.refresh
      end
      pbEraseEscapePoint
      return true
    end
    return false
  end)
end

#==============================================================================#
# This section of the code handles the item that calls Rock Smash.             #
#==============================================================================#

if USING_ROCK_SMASH_ITEM
  HiddenMoveHandlers::CanUseMove.delete(:ROCKSMASH)
  HiddenMoveHandlers::UseMove.delete(:ROCKSMASH)
  
  ItemHandlers::UseFromBag.add(:SLEDGEHAMMER, proc do |item|
    if $game_player.pbFacingEvent && $game_player.pbFacingEvent.name == "Roca"
      return 2
    end
    return false
  end)
  
  ItemHandlers::UseInField.add(:SLEDGEHAMMER, proc do |item|
    $game_player.pbFacingEvent.start
    return true
  end)
  
  def Kernel.pbRockSmash
    if !$PokemonBag.pbHasItem?(:SLEDGEHAMMER)
      Kernel.pbMessage(_INTL("Es una roca algo quebradiza, de seguro algo podría destrozarla."))
      return false
    end
    item = PBItems.getName(getConst(PBItems,:SLEDGEHAMMER))
    if Kernel.pbConfirmMessage(_INTL("Esta roca parece demolible. ¿Te gustaría usar el {1}?", item))
      Kernel.pbMessage(_INTL("¡{1} usó su {2}!",$Trainer.name, item))
      pbSEPlay("Rock Smash")
      return true
    end
    return false
  end
end


#==============================================================================#
# This section of code handles the item that calls Strength.                   #
#==============================================================================#

if USING_STRENGTH_ITEM
  HiddenMoveHandlers::CanUseMove.delete(:STRENGTH)
  HiddenMoveHandlers::UseMove.delete(:STRENGTH)
  
  def Kernel.pbStrength
    if $PokemonMap.strengthUsed
      Kernel.pbMessage(_INTL("Una superfuerza podría ser capaz de mover esta roca."))
      return false
    end
    if !$PokemonBag.pbHasItem?(:STRENGTHGAUNTLET) && !$DEBUG
      Kernel.pbMessage(_INTL("Es una gran roca, ¿podría ser movida a un lado con algo?."))
      return false
    end
    itemname = PBItems.getName(getConst(PBItems,STRENGTH_ITEM))
    Kernel.pbMessage(_INTL("Una superfuerza podría ser capaz de mover esta gran roca.\1"))
    if Kernel.pbConfirmMessage(_INTL("¿Te gustaría utilizar tus {1}?", itemname))
      Kernel.pbMessage(_INTL("¡{1} usó sus {2}!",
          $Trainer.name, itemname))
      Kernel.pbMessage(_INTL("¡Los {1} hicieron posible que se puedan empujar las rocas!",itemname))
      pbSEPlay("increase")
      $PokemonMap.strengthUsed = true
      return true
    end
    return false
  end
  
  ItemHandlers::UseFromBag.add(STRENGTH_ITEM, proc do
    if $game_player.pbFacingEvent && $game_player.pbFacingEvent.name == "Piedra Rod"
      return 2
    end
    return false
  end)
  
  ItemHandlers::UseInField.add(STRENGTH_ITEM, proc { Kernel.pbStrength })
end


#==============================================================================#
# This section of code handles the item that calls Cut.                        #
#==============================================================================#

if USING_CUT_ITEM
  HiddenMoveHandlers::CanUseMove.delete(:CUT)
  HiddenMoveHandlers::UseMove.delete(:CUT)
  
  def Kernel.pbCut
    if !$PokemonBag.pbHasItem?(:AXE) && !$DEBUG
      Kernel.pbMessage(_INTL("Al parecer este árbol se puede cortar."))
      return false
    end
    Kernel.pbMessage(_INTL("¡Al parecer este árbol se puede cortar!\1"))
    if Kernel.pbConfirmMessage(_INTL("¿Quiere cortarlo?"))
      itemname = PBItems.getName(getConst(PBItems,CUT_ITEM))
      Kernel.pbMessage(_INTL("¡{1} usó su {2}!",$Trainer.name,itemname))
      pbSEPlay("Cut")
      pbSmashEvent($game_player.pbFacingEvent)
      return true
    end
    return false
  end
  
  ItemHandlers::UseFromBag.add(CUT_ITEM, proc do
    if $game_player.pbFacingEvent && $game_player.pbFacingEvent.name == "Arbol"
      return 2
    end
    return false
  end)
  
  ItemHandlers::UseInField.add(CUT_ITEM, proc { $game_player.pbFacingEvent.start })
end


#==============================================================================#
# Inicialización del ARBORIETE en PokemonGlobalMetadata                        #
#==============================================================================#

class PokemonGlobalMetadata
  attr_accessor :arboriete_mode
  
  alias_method :initialize_before_arboriete, :initialize
  def initialize
    initialize_before_arboriete
    @arboriete_mode ||= 0  # 0 = Suave (HeadbuttLow), 1 = Fuerte (HeadbuttHigh)
  end
end

#==============================================================================#
# This section of code handles the item that calls Headbutt with ARBORIETE.    #
#==============================================================================#

if USING_HEADBUTT_ITEM
  HiddenMoveHandlers::CanUseMove.delete(:HEADBUTT)
  HiddenMoveHandlers::UseMove.delete(:HEADBUTT)
  
  def Kernel.pbArborieteMode
    $PokemonGlobal.arboriete_mode = 0 if $PokemonGlobal.arboriete_mode.nil?
    current_mode = $PokemonGlobal.arboriete_mode == 0 ? _INTL("Embestida Suave") : _INTL("Embestida Fuerte")
    Kernel.pbMessage(_INTL("Modo actual: {1}", current_mode))
    
    if Kernel.pbConfirmMessage(_INTL("¿Deseas cambiar de modo?"))
      $PokemonGlobal.arboriete_mode = ($PokemonGlobal.arboriete_mode == 0) ? 1 : 0
      new_mode = $PokemonGlobal.arboriete_mode == 0 ? _INTL("Embestida Suave") : _INTL("Embestida Fuerte")
      Kernel.pbMessage(_INTL("Modo cambiado a: {1}", new_mode))
      return 1
    end
    
    return 0
  end
  
  def Kernel.pbArborieteEffect(event)
    $PokemonGlobal.arboriete_mode = 0 if $PokemonGlobal.arboriete_mode.nil?
    encounter_type = $PokemonGlobal.arboriete_mode == 0 ? EncounterTypes::HeadbuttLow : EncounterTypes::HeadbuttHigh
    
    if !pbEncounter(encounter_type)
      Kernel.pbMessage(_INTL("No pasó nada..."))
    end
  end
  
  def Kernel.pbArborieteHeadbutt(event)
    if Kernel.pbConfirmMessage(_INTL("Este árbol parece habitado por ciertos Pokémon.\n¿Quieres utilizar el Arboriete?"))
      Kernel.pbMessage(_INTL("¡{1} usó el {2}!", $Trainer.name, PBItems.getName(getConst(PBItems, HEADBUTT_ITEM))))
      Kernel.pbArborieteEffect(event)
    end
    Input.update
    return
  end
  
  ItemHandlers::UseFromBag.add(HEADBUTT_ITEM, proc do |item|
    Kernel.pbArborieteMode
    return 1
  end)
  
  ItemHandlers::UseInField.add(HEADBUTT_ITEM, proc do |item|
    $game_temp.in_menu = false
    facingEvent = $game_player.pbFacingEvent
    if facingEvent && facingEvent.name == "HeadbuttTree"
      Kernel.pbArborieteHeadbutt(facingEvent)
    end
    return true
  end)
end
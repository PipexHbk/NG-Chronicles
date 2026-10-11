#===============================================================================
# Sistema de Zahorí Mejorado (Itemfinder) - CON ANIMACIÓN
#===============================================================================

class ItemFinderSystem
  attr_accessor :active
  attr_accessor :nearbyState # 0 = lejos, 1 = cerca (amarillo), 2 = muy cerca (rojo)
  attr_accessor :lastState
  
  def initialize
    @active = false
    @nearbyState = 0
    @lastState = 0
    @iconSprite = nil
    @animatedBitmap = nil
    @currentFrame = 0
    @frameCount = 8 # Número de frames en tu sprite sheet
    @frameWidth = 32 # Ancho de cada frame
    @frameDelay = 8 # Velocidad de animación (menor = más rápido)
    @frameTimer = 0
  end
  
  def toggle
    @active = !@active
    if @active
      showIcon
      checkNearbyItems
    else
      hideIcon
    end
  end
  
  def showIcon
    return if @iconSprite
    
    # Cargar el sprite sheet animado
    @animatedBitmap = AnimatedBitmap.new("Graphics/Icons/radar")
    
    # Crear el sprite
    @iconSprite = Sprite.new
    @iconSprite.bitmap = Bitmap.new(@frameWidth, @frameWidth)
    @iconSprite.x = 10
    @iconSprite.y = 10
    @iconSprite.z = 99999
    @iconSprite.opacity = 255
    
    # Dibujar el primer frame
    updateFrame
  end
  
  def hideIcon
    return if !@iconSprite
    @iconSprite.bitmap.dispose if @iconSprite.bitmap
    @iconSprite.dispose
    @animatedBitmap.dispose if @animatedBitmap
    @iconSprite = nil
    @animatedBitmap = nil
    @nearbyState = 0
    @lastState = 0
    @currentFrame = 0
    @frameTimer = 0
  end
  
  def deactivate
    @active = false
    hideIcon
  end
  
  def updateFrame
    return if !@iconSprite || !@animatedBitmap
    
    # Limpiar el bitmap actual
    @iconSprite.bitmap.clear
    
    # Calcular la posición del frame en el sprite sheet
    srcX = @currentFrame * @frameWidth
    srcRect = Rect.new(srcX, 0, @frameWidth, @frameWidth)
    
    # Dibujar el frame actual
    @iconSprite.bitmap.blt(0, 0, @animatedBitmap.bitmap, srcRect)
  end
  
  def checkNearbyItems
    return if !@active
    
    event = pbClosestHiddenItem
    
    if !event
      # No hay objetos cerca
      @nearbyState = 0
      @lastState = 0
      updateIconColor
      return
    end
    
    # Calcular distancia
    offsetX = (event.x - $game_player.x).abs
    offsetY = (event.y - $game_player.y).abs
    distance = [offsetX, offsetY].max
    
    # Determinar estado según distancia
    if offsetX == 0 && offsetY == 0
      # Estás exactamente sobre el objeto
      @nearbyState = 2
      if @lastState != 2
        pbSEPlay("Mining reveal full", 80)
        @lastState = 2
      end
    elsif distance <= 1 && isFacingItem?(event)
      # Estás a 1 casilla y mirando hacia el objeto
      @nearbyState = 2
      if @lastState != 2
        pbSEPlay("Mining reveal full", 80)
        @lastState = 2
      end
    elsif distance <= 4
      # Estás a 4 casillas o menos
      @nearbyState = 1
      if @lastState != 1
        pbSEPlay("Mining reveal", 80)
        @lastState = 1
      end
    else
      # Estás lejos
      @nearbyState = 0
      @lastState = 0
    end
    
    updateIconColor
  end
  
  def isFacingItem?(event)
    case $game_player.direction
    when 2 # Abajo
      return event.x == $game_player.x && event.y == $game_player.y + 1
    when 4 # Izquierda
      return event.x == $game_player.x - 1 && event.y == $game_player.y
    when 6 # Derecha
      return event.x == $game_player.x + 1 && event.y == $game_player.y
    when 8 # Arriba
      return event.x == $game_player.x && event.y == $game_player.y - 1
    end
    return false
  end
  
  def updateIconColor
    return if !@iconSprite
    
    case @nearbyState
    when 0 # Normal (sin color)
      @iconSprite.color = Color.new(0, 0, 0, 0)
    when 1 # Amarillo (cerca)
      @iconSprite.color = Color.new(255, 255, 0, 100)
    when 2 # Rojo (muy cerca)
      @iconSprite.color = Color.new(255, 0, 0, 120)
    end
  end
  
  def update
    return if !@active || !@iconSprite
    
    # Actualizar animación
    @frameTimer += 1
    if @frameTimer >= @frameDelay
      @frameTimer = 0
      @currentFrame = (@currentFrame + 1) % @frameCount
      updateFrame
    end
    
    # Parpadeo según estado
    if @nearbyState > 0
      blinkFrame = (Graphics.frame_count / 15) % 2
      if blinkFrame == 0
        @iconSprite.color = Color.new(0, 0, 0, 0)
      else
        case @nearbyState
        when 1
          @iconSprite.color = Color.new(255, 255, 0, 100) # Amarillo
        when 2
          @iconSprite.color = Color.new(255, 0, 0, 120) # Rojo
        end
      end
    else
      @iconSprite.color = Color.new(0, 0, 0, 0)
    end
  end
end

# Inicializar el sistema globalmente
$itemFinder = ItemFinderSystem.new if !$itemFinder

#===============================================================================
# Events para desactivar el Zahorí automáticamente
#===============================================================================

Events.onWildBattleEnd += proc { |sender, e|
  $itemFinder.deactivate if $itemFinder
}

Events.onMapChange += proc { |sender, e|
  $itemFinder.deactivate if $itemFinder
}

if defined?(Events.onEndBattle)
  Events.onEndBattle += proc { |sender, e|
    $itemFinder.deactivate if $itemFinder
  }
end

#===============================================================================
# Actualizar el Zahorí cada frame
#===============================================================================

class Scene_Map
  alias itemfinder_update update
  def update
    itemfinder_update
    if $itemFinder && $itemFinder.active
      $itemFinder.update
    end
  end
end

#===============================================================================
# Actualizar al moverse
#===============================================================================

Events.onStepTaken += proc { |sender, e|
  if $itemFinder && $itemFinder.active
    $itemFinder.checkNearbyItems
  end
}

#===============================================================================
# Actualizar al girar sin moverse
#===============================================================================

class Game_Player
  alias itemfinder_turn_left turn_left
  def turn_left
    itemfinder_turn_left
    $itemFinder.checkNearbyItems if $itemFinder && $itemFinder.active
  end
  
  alias itemfinder_turn_right turn_right
  def turn_right
    itemfinder_turn_right
    $itemFinder.checkNearbyItems if $itemFinder && $itemFinder.active
  end
  
  alias itemfinder_turn_up turn_up
  def turn_up
    itemfinder_turn_up
    $itemFinder.checkNearbyItems if $itemFinder && $itemFinder.active
  end
  
  alias itemfinder_turn_down turn_down
  def turn_down
    itemfinder_turn_down
    $itemFinder.checkNearbyItems if $itemFinder && $itemFinder.active
  end
end
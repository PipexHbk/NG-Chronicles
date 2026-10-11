#===============================================================================
#    Atajo rápido para usar Pokéballs e interfaz para seleccionarla
#           Para Pokémon Essentials v16/BES
#===============================================
# Inspirado por la interfaz similar que podemos encontrar en DBK
#===============================================
# Para instalar requiere editar un par de scripts.
=begin
En PokeBattle_Battle hay que buscar la linea: 
    elsif cmd==4   # Call
Sobre el, vamos a pegar esta linea:
    elsif cmd==5; commandDone=true  

En PokeBattle_Scene(v16) o PokeBattle_SceneCommands(BES) buscamos: 
    elsif Input.trigger?(Input::B) && index==2 && @lastcmd[0]!=2 # Cancel
Y sobre ella, vamos a pegar este bloque:
 #-----------     
  elsif (Input.trigger?(Input::R)) && (!$game_switches[NO_CAPTURE_SWITCH] ||
      hasBalls? || !pbInSafari? || !pbInBugContest?)
    if @battle.opponent 
      @battle.pbDisplayPaused(_INTL("¡No puedes capturar pokémon que no son tuyos!"))
      return -1
    elsif @battle.doublebattle
      @battle.pbDisplayPaused(_INTL("¡No se puede apuntar cuando hay más de un Pokémon!"))
      return -1
    end
    pbPlayDecisionSE()
    if pbUseBallInBattle(@battle, 1)
      cw.index = 5
      ret=cw.index
      @lastcmd[index]=0
      return ret
    end
  #-----------     
      
=end
#===============================================================================



begin
PluginManager.register({
  :name    => "Atajo rápido para usar Pokéballs",
  :version => "1",
  :credits => "Clara"
})
rescue;end

module PokeBattle_SceneConstants
  BALLBUTTON_X        = 6
  BALLBUTTON_Y        = defined?(PokeBattle_SceneConstants::INFOBUTTON_Y) ? PokeBattle_SceneConstants::INFOBUTTON_Y-48 : 240

  BALLBASECOLOR        = Color.new(80,80,88)
  BALLSHADOWCOLOR      = Color.new(160,160,168)
  BALL2BASECOLOR       = Color.new(252,252,252)
  BALL2SHADOWCOLOR     = Color.new(88,88,88)
end




class BallSelectorInterface
  attr_reader :index
  attr_reader :selected_ball
  
  def initialize
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @sprites = {}
    @index = 0
    @selected_ball = nil
    @ball_list = []
    @ball_counts = []
    
    refresh_ball_list
    if @ball_list.length <= 3
      @visible_balls = @ball_list.length
    else
      @visible_balls = 5
    end
    @offset = 0
    @ball_spacing = 80
    @start_x = Graphics.width / 2 - (@visible_balls * @ball_spacing) / 2 + 16
    @ball_y = Graphics.height / 2 - 64
      
    
    $lastBallUsed = nil if !$lastBallUsed
    set_last_used_position

    create_sprites
    update_display
  end
  
  def create_sprites
    # Fondo customizable
    @sprites["bg"] = Sprite.new(@viewport)
    bg_path = "Graphics/Pictures/Battle/BallSelector/background"
    @sprites["bg"].bitmap = AnimatedBitmap.new(bg_path).bitmap
    
    for i in 0...@visible_balls
      @sprites["ball_bg_#{i}"] = Sprite.new(@viewport)
      bg_path = "Graphics/Pictures/Battle/BallSelector/ball_bg"
      @sprites["ball_bg_#{i}"].bitmap = AnimatedBitmap.new(bg_path).bitmap
      @sprites["ball_bg_#{i}"].oy = 0 
      @sprites["ball_bg_#{i}"].ox = 0 
      
      @sprites["selector_#{i}"] = Sprite.new(@viewport)
      selector_path = "Graphics/Pictures/Battle/BallSelector/selector"
      @sprites["selector_#{i}"].bitmap = AnimatedBitmap.new(selector_path).bitmap
      @sprites["selector_#{i}"].oy = 0 
      @sprites["selector_#{i}"].ox = 0 

      @sprites["selector_#{i}"].visible = false
      @sprites["ball_#{i}"] = Sprite.new(@viewport)
    end
    
    @sprites["counts"] = Sprite.new(@viewport)
    @sprites["counts"].bitmap = Bitmap.new(Graphics.width, Graphics.height)
    
    @sprites["description"] = Sprite.new(@viewport)
    @sprites["description"].bitmap = Bitmap.new(Graphics.width, Graphics.height)

    @sprites["leftarrow"] = AnimatedSprite.new("Graphics/Pictures/leftarrow", 8, 40, 28, 6, @viewport)
    @sprites["leftarrow"].x = @start_x - 64
    @sprites["leftarrow"].y = @ball_y + 8
    @sprites["leftarrow"].visible = false
    @sprites["leftarrow"].play
    
    @sprites["rightarrow"] = AnimatedSprite.new("Graphics/Pictures/rightarrow", 8, 40, 28, 6, @viewport)
    @sprites["rightarrow"].x = @start_x + (@visible_balls * @ball_spacing) - 8
    @sprites["rightarrow"].y = @ball_y + 8
    @sprites["rightarrow"].visible = false
    @sprites["rightarrow"].play
  end
  
  
  def refresh_ball_list
    @ball_list.clear
    @ball_counts.clear
    for i in 1..PBItems.maxValue
      if pbIsPokeBall?(i) && $PokemonBag.pbQuantity(i) > 0
        @ball_list.push(i)
        @ball_counts.push($PokemonBag.pbQuantity(i))
      end
    end
    combined = []
    for j in 0...@ball_list.length
      combined.push([@ball_list[j], @ball_counts[j]])
    end
    combined.sort! { |a, b| a[0] <=> b[0] }
    
    @ball_list.clear
    @ball_counts.clear
    for item in combined
      @ball_list.push(item[0])
      @ball_counts.push(item[1])
    end
    if @ball_list.length == 0
      @ball_list.push(nil)
      @ball_counts.push(0)
    end
  end
  
  def update_display
    center_position = @visible_balls / 2
    @sprites["counts"].bitmap.clear
    @sprites["description"].bitmap.clear
    
    count_texts = []
    
    for i in 0...@visible_balls
      relative_pos = i - center_position
      ball_index = (@index + relative_pos) % @ball_list.length
      
      if ball_index < 0
        ball_index = @ball_list.length + ball_index
      end
      
      if @ball_list.length > 0 && @ball_list[ball_index]
        x = @start_x + (i * @ball_spacing)
        y = @ball_y
        
        if i == center_position #Seleccionada
          @sprites["selector_#{i}"].x = x - 16
          @sprites["selector_#{i}"].y = y - 16
          @sprites["selector_#{i}"].visible = true
          @sprites["selector_#{i}"].opacity=255
          @sprites["ball_bg_#{i}"].opacity=255
        else
          unless i == 0 || i == 4
            @sprites["ball_#{i}"].opacity=150
          else
            @sprites["ball_#{i}"].opacity=75
            @sprites["ball_bg_#{i}"].opacity=120
          end
          @sprites["selector_#{i}"].visible = false
        end
        
        @sprites["ball_bg_#{i}"].x = x - 8
        @sprites["ball_bg_#{i}"].y = y - 8
        @sprites["ball_bg_#{i}"].visible = true
        
        ball_filename = sprintf("Graphics/Icons/item%03d", @ball_list[ball_index])
        if pbResolveBitmap(ball_filename)
          if @sprites["ball_#{i}"].bitmap
            @sprites["ball_#{i}"].bitmap.dispose
          end
          @sprites["ball_#{i}"].bitmap = AnimatedBitmap.new(ball_filename).bitmap
          @sprites["ball_#{i}"].x = x
          @sprites["ball_#{i}"].y = y
          @sprites["ball_#{i}"].visible = true
        end
        
        count_texts.push([
          @ball_counts[ball_index].to_s,
          x + 24,
          y + 56,
          2,
          PokeBattle_SceneConstants::BALL2BASECOLOR,
          PokeBattle_SceneConstants::BALL2SHADOWCOLOR,true
        ])
        
      else
        @sprites["ball_#{i}"].visible = false
        @sprites["selector_#{i}"].visible = false
        @sprites["ball_bg_#{i}"].visible = false
      end
    end
    
    if count_texts.length > 0
      pbSetSmallFont(@sprites["counts"].bitmap)
      pbDrawTextPositions(@sprites["counts"].bitmap, count_texts)
    end
    
    if @ball_list[@index] && @ball_list[@index] != nil
      item_name = PBItems.getName(@ball_list[@index])
      item_desc = pbGetMessage(MessageTypes::ItemDescriptions, @ball_list[@index])
      pbSetSystemFont(@sprites["description"].bitmap)
      
      pbDrawTextPositions(@sprites["description"].bitmap, [
        [item_name, 
        Graphics.width/2, 
        @ball_y - 54, 2, 
        PokeBattle_SceneConstants::BALLBASECOLOR,
        PokeBattle_SceneConstants::BALLSHADOWCOLOR]
      ])
      
      pbSetSmallFont(@sprites["description"].bitmap)
      drawFormattedTextEx(@sprites["description"].bitmap,
        24,
        @ball_y + 80 + 4,
        Graphics.width-24,
        _INTL(item_desc),
        PokeBattle_SceneConstants::BALLBASECOLOR,
        PokeBattle_SceneConstants::BALLSHADOWCOLOR, 24)
    end
    
    if @visible_balls > 0
      @sprites["leftarrow"].visible = true
      @sprites["rightarrow"].visible = true
    else
      @sprites["leftarrow"].visible = false
      @sprites["rightarrow"].visible = false
    end
  end
  
  def update_input
    if Input.trigger?(Input::LEFT)
      @index -= 1
      @index = @ball_list.length - 1 if @index < 0
      pbSEPlay("SE_Select1")
      update_display
    elsif Input.trigger?(Input::RIGHT) 
      @index += 1
      @index = 0 if @index >= @ball_list.length
      pbSEPlay("SE_Select1")
      update_display
    elsif Input.trigger?(Input::C) || Input.trigger?(Input::A)
      if @ball_list[@index] && @ball_list[@index] != nil
        @selected_ball = @ball_list[@index]
        pbSEPlay("SE_Select2")
        return true
      else
        pbPlayBuzzerSE()
        return nil
      end
    elsif Input.trigger?(Input::B)
      pbPlayCancelSE()
      return false
    end
    return nil
  end
  
  
  
  def update
    @sprites["leftarrow"].update
    @sprites["rightarrow"].update
  end

  def dispose
    for key in @sprites.keys
      if @sprites[key].respond_to?(:bitmap) && @sprites[key].bitmap
        @sprites[key].bitmap.dispose
      end
      @sprites[key].dispose
    end
    @sprites.clear
    @viewport.dispose
  end
  
  def set_last_used_position
    if $lastBallUsed && $lastBallUsed != nil
      # Verificar si aún tienes esa ball
      if $PokemonBag.pbQuantity($lastBallUsed) > 0
        for i in 0...@ball_list.length
          if @ball_list[i] == $lastBallUsed
            @index = i
            return
          end
        end
      else
        $lastBallUsed = nil
      end
    end
  end

  
end

#===============================================================================
# Función principal para la selección
#===============================================================================
def pbBallSelector
  # Verificar si hay bolas disponibles usando pbIsPokeBall?
  has_balls = false
  
  for i in 1..PBItems.maxValue
    if pbIsPokeBall?(i) && $PokemonBag.pbQuantity(i) > 0
      has_balls = true
      break
    end
  end
  
  if !has_balls
    pbPlayBuzzerSE()
    return nil
  end
  
  ball_selector = BallSelectorInterface.new
  
  loop do
    Graphics.update
    Input.update
    ball_selector.update # Actualizar animaciones
    
    result = ball_selector.update_input
    
    if result == true
      selected = ball_selector.selected_ball
      ball_selector.dispose
      return selected
    elsif result == false  
      ball_selector.dispose
      return nil
    end
  end
end

#===============================================================================
# Función para usar en batalla
#===============================================================================

def pbUseBallInBattle(battle, battler_index)
  selected_ball = pbBallSelector()
  
  if selected_ball && selected_ball != nil
    if $PokemonBag.pbQuantity(selected_ball) > 0
      $lastBallUsed = selected_ball
      battle.pbThrowPokeBall(battler_index, selected_ball)
      $PokemonBag.pbDeleteItem(selected_ball, 1)
      $lastBallUsed = nil if $PokemonBag.pbQuantity(selected_ball) <= 0
      return true
    else
      pbPlayBuzzerSE()
      p pbMessage(_INTL("Ya no tienes esa Poké Ball.")) if $DEBUG
      return false
    end
  end
  
  return false
end

#===============================================================================
# Función para verificar si hay bolas
#===============================================================================

def hasBalls?
  for i in 1..PBItems.maxValue
    if pbIsPokeBall?(i) && $PokemonBag.pbQuantity(i) > 0
      return true
    end
  end
  return false
end

#===============================================================================
# El boton se coloca aqui
#===============================================================================

class CommandMenuDisplay

  alias initialize_BallUI initialize
  def initialize(viewport=nil)
    initialize_BallUI(viewport)
    # BES-T Info combate
    @iconBall=IconSprite.new(0,0,viewport)
    unless $game_switches[NO_CAPTURE_SWITCH] || !hasBalls? || pbInSafari? || pbInBugContest?
      @iconBall.setBitmap("Graphics/Pictures/Battle/BallSelector/ballButton")
      @iconBall.y=PokeBattle_SceneConstants::BALLBUTTON_Y
      @iconBall.x=PokeBattle_SceneConstants::BALLBUTTON_X
    end
  end
  
  alias x_BallUI x=
  def x=(value)
    x_BallUI(value)
    @iconBall.x=value if @iconBall
  end

  alias y_BallUI y=
  def y=(value)
    y_BallUI(value)
    @iconBall.y=value if @iconBall
  end

  alias z_BallUI z=
  def z=(value)
    z_BallUI(value)
    @iconBall.z=value if @iconBall
  end

  alias ox_BallUI ox=
  def ox=(value)
    ox_BallUI(value)
    @iconBall.ox=value if @iconBall
  end

  alias oy_BallUI oy=
  def oy=(value)
    oy_BallUI(value)
    @iconBall.oy=value if @iconBall
  end
  
  alias visible_BallUI visible=
  def visible=(value)
    visible_BallUI(value)
    @iconBall.visible=value if @iconBall
  end

  alias color_BallUI color=
  def color=(value)
    color_BallUI(value)
    @iconBall.color=value if @iconBall
  end

  alias dispose_BallUI dispose
  def dispose
    dispose_BallUI
    @iconBall.dispose if @iconBall
  end

  alias update_BallUI update
  def update
    update_BallUI
    @iconBall.update
  end
end
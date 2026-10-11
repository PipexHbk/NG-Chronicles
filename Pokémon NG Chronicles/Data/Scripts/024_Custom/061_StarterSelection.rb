#===============================================================================
# DiegoWT's Starter Selection script
#===============================================================================

# Para llamarlo usen "DiegoWTsStarterSelection.new(x,y,z,id1,id2,id3)",

# Por ejemplo DiegoWTsStarterSelection.new(:PHAMTOR,:NYXARA,:PSYPION,1,2,3)
# donde 1, 2, 3 son los IDs de los eventos de cada pokéball


# Level of your starters:
  STARTERL = 5
  
 # Cambia fondo(1 for HGSS, 2 for BW):
  INSTYLE = 2

# Forma de cada especie (si tienes formas alternativas:
  STARTER1F = 0 # First Starter
  STARTER2F = 0 # Second Starter
  STARTER3F = 0 # Third Starter
 
# Valores horizontales y verticales para editar la posición inicial:
  STARTER1X = -20; STARTER1Y = 10 # First Starter
  STARTER2X = 0; STARTER2Y = 0 # Second Starter
  STARTER3X = 20; STARTER3Y = 10 # Third Starter
# Aquí, para las líneas horizontales, se dejan los números negativos y los positivos
# unos tienen razón. Para las líneas verticales, los números negativos son hacia arriba y el
# positivos están abajo.
 
# Cambia el tamaño del circulo:
  STARTERCZ = 1 # 0 is normal size; 1 is double the size
#===============================================================================
class DiegoWTsStarterSelection
  def initialize(pkmn1,pkmn2,pkmn3,event_id_1=nil,event_id_2=nil,event_id_3=nil)
    @select = nil
    @frame = 0
    @selframe = 0
    @endscene = 0
    @pkmn1 = pkmn1; @pkmn2 = pkmn2; @pkmn3 = pkmn3
    @map_id = $game_map.map_id
    @event_id_1 = event_id_1  # ID del evento de la pokéball izquierda
    @event_id_2 = event_id_2  # ID del evento de la pokéball centro
    @event_id_3 = event_id_3  # ID del evento de la pokéball derecha
    
    @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z = 99999
    @sprites = {}
    
    @sprites["starterbg"] = IconSprite.new(0,0,@viewport) 
    @sprites["starterbg"].opacity = 0
    @sprites["typebg"] = IconSprite.new(0,0,@viewport)   
    @sprites["typebg"].opacity = 0
    if INSTYLE == 2
      @sprites["starterbg"].setBitmap("Graphics/Pictures/DiegoWT's Starter Selection/starterbg_custom")
      @sprites["starterbg"].color = Color.new(255,255,255,105)
      @sprites["typebg"].setBitmap("Graphics/Pictures/DiegoWT's Starter Selection/starterbg_custom")
    else
      @sprites["starterbg"].setBitmap("Graphics/Pictures/DiegoWT's Starter Selection/starterbg")
      @sprites["typebg"].setBitmap("Graphics/Pictures/DiegoWT's Starter Selection/starterbg")
      @sprites["typebg"].color = Color.new(-255,-255,-255,25)
    end
    
    @sprites["base"] = IconSprite.new(0,0,@viewport)   
    @sprites["base"].setBitmap("Graphics/Pictures/DiegoWT's Starter Selection/base")
    @sprites["base"].opacity = 0
    
    @sprites["shadow_1"] = IconSprite.new(56,212,@viewport)
    @sprites["shadow_2"] = IconSprite.new(210,212,@viewport)
    @sprites["shadow_3"] = IconSprite.new(364,212,@viewport)
    for i in 1..3
      @sprites["shadow_#{i}"].setBitmap("Graphics/Pictures/DiegoWT's Starter Selection/shadow")
      @sprites["shadow_#{i}"].opacity=0
    end
    
    @sprites["ball_1"] = IconSprite.new(102,188,@viewport)
    @sprites["ball_2"] = IconSprite.new(256,188,@viewport)
    @sprites["ball_3"] = IconSprite.new(410,188,@viewport)
    for i in 1..3
      @sprites["ball_#{i}"].setBitmap("Graphics/Pictures/DiegoWT's Starter Selection/ball#{i}")
      @sprites["ball_#{i}"].ox=@sprites["ball_#{i}"].bitmap.width/2
      @sprites["ball_#{i}"].oy=@sprites["ball_#{i}"].bitmap.height/2
      @sprites["ball_#{i}"].opacity = 0
    end
    
    @sprites["select"] = IconSprite.new(102,188,@viewport) # Outline selection
    @sprites["select"].setBitmap("Graphics/Pictures/DiegoWT's Starter Selection/sel")
    @sprites["select"].ox = @sprites["select"].bitmap.width/2
    @sprites["select"].oy = @sprites["select"].bitmap.height/2
    @sprites["select"].visible = false
    @sprites["selection"] = IconSprite.new(224,32,@viewport) # Hand selection
    @sprites["selection"].setBitmap("Graphics/Pictures/DiegoWT's Starter Selection/select")
    @sprites["selection"].visible = false
    
    @sprites["ballbase"] = IconSprite.new(0,0,@viewport)
    @sprites["ballbase"].setBitmap("Graphics/Pictures/DiegoWT's Starter Selection/ballbase")
    if STARTERCZ >= 1
      @sprites["ballbase"].setBitmap("Graphics/Pictures/DiegoWT's Starter Selection/ballbase2x")
      @sprites["ballbase"].zoom_x = 0.5
      @sprites["ballbase"].zoom_y = 0.5
    end
    @sprites["ballbase"].ox = @sprites["ballbase"].bitmap.width/2
    @sprites["ballbase"].oy = @sprites["ballbase"].bitmap.height/2
    @sprites["ballbase"].opacity = 0
    
    @data = {}
    @data["pkmn_1"] = PokeBattle_Pokemon.new(@pkmn1,STARTERL)
    @data["pkmn_1"].form = STARTER1F
    @data["pkmn_2"] = PokeBattle_Pokemon.new(@pkmn2,STARTERL)
    @data["pkmn_2"].form = STARTER2F
    @data["pkmn_3"] = PokeBattle_Pokemon.new(@pkmn3,STARTERL)
    @data["pkmn_3"].form = STARTER3F
    for i in 1..3
    @sprites["pkmn_#{i}"] = PokemonSprite.new(@viewport)
    @sprites["pkmn_#{i}"].ox = 180/2
    @sprites["pkmn_#{i}"].oy = 200/2
      @pokemon = @data["pkmn_#{i}"]
      @data.values.each { |pkmn|
        if pkmn.form != 0
          pkmn.calcStats
          pkmn.resetMoves
        end
      }
      @sprites["pkmn_#{i}"].setPokemonBitmap(@pokemon)
      @sprites["pkmn_#{i}"].opacity = 0
      @sprites["pkmn_#{i}"].z = 2
    end
    @sprites["pkmn_1"].x = STARTER1X + 256
    @sprites["pkmn_1"].y = STARTER1Y + 148
    @sprites["pkmn_2"].x = STARTER2X + 256
    @sprites["pkmn_2"].y = STARTER2Y + 148
    @sprites["pkmn_3"].x = STARTER3X + 256
    @sprites["pkmn_3"].y = STARTER3Y + 148
    
    for i in 1..2
      @sprites["choice#{i}"] = IconSprite.new(370,(i-1)*46+174,@viewport)
        @sprites["choice#{i}"].setBitmap("Graphics/Pictures/DiegoWT's Starter Selection/choice")
      @sprites["choice#{i}"].src_rect = Rect.new((i-1)*140,0,140,48)
      @sprites["choice#{i}"].visible = false
    end
    @sprites["choicesel"] = IconSprite.new(370,174,@viewport)
      @sprites["choicesel"].setBitmap("Graphics/Pictures/DiegoWT's Starter Selection/choice")
    @sprites["choicesel"].src_rect = Rect.new(0,96,140,48)
    @sprites["choicesel"].visible = false
    @sprites["overlay"] = BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    @overlay = @sprites["overlay"].bitmap
    pbSetSystemFont(@overlay)
    @sprites["textbox"]=Kernel.pbCreateMessageWindow
    @sprites["textbox"].letterbyletter=false
    @sprites["textbox"].setSkin("Graphics/Windowskins/speech pl 20")
    @sprites["textbox"].y = @sprites["textbox"].y - 16
    pbOpenScene
  end
 
  def pbOpenScene
    25.times do
      @sprites["starterbg"].opacity += 200/20
      @sprites["base"].opacity += 255/20
      @sprites["shadow_1"].opacity += 255/20
      @sprites["shadow_2"].opacity += 255/20
      @sprites["shadow_3"].opacity += 255/20
      @sprites["ball_1"].opacity += 255/20
      @sprites["ball_2"].opacity += 255/20
      @sprites["ball_3"].opacity += 255/20

      pbWait(1)
    end
    @sprites["textbox"].text = _INTL("<ac>¿Cuál decides?</ac>")
    pbStartChoosing
  end
 
  def pbAnimation
    if @frame < 4
      @sprites["ball_#{@select}"].x -= 2
      @sprites["ball_#{@select}"].angle += 2
      @sprites["shadow_#{@select}"].x -= 2
      @sprites["select"].x -= 2
      @sprites["select"].angle += 2
    elsif @frame >= 4 && @frame < 10
      @sprites["ball_#{@select}"].x += 2
      @sprites["ball_#{@select}"].angle -= 2
      @sprites["shadow_#{@select}"].x += 2
      @sprites["select"].x += 2
      @sprites["select"].angle -= 2
    elsif @frame >= 10 && @frame < 15
      @sprites["ball_#{@select}"].x -= 2
      @sprites["ball_#{@select}"].angle += 2
      @sprites["shadow_#{@select}"].x -= 2
      @sprites["select"].x -= 2
      @sprites["select"].angle += 2
    elsif @frame >= 15 && @frame < 16
      @sprites["ball_#{@select}"].x = @oldx
      @sprites["ball_#{@select}"].angle = 0
      @sprites["select"].x = @oldx
      @sprites["select"].angle = 0
      @sprites["shadow_#{@select}"].x = @oldx-46
    elsif @frame == 50
      @frame = 0
    end
    @frame += 1
    if @selframe < 15
      @sprites["selection"].y += 1
    elsif @selframe >= 15 && @selframe < 22
      @sprites["selection"].y -= 2
    elsif @selframe == 22
      @selframe = 0
    end
    @selframe += 1
    intensity = (Graphics.frame_count%40)*12
    intensity = 480-intensity if intensity>240
    @sprites["select"].opacity = intensity
  end
 
  def pbStartChoosing
    @x = [nil,102,256,410]
    @y = [nil,188,188,188]
    while @endscene == 0
      pbUpdateSpriteHash(@sprites)
      Graphics.update
      Input.update
      if Input.trigger?(Input::RIGHT) || Input.trigger?(Input::LEFT) ||
        Input.trigger?(Input::A) || Input.trigger?(Input::C) ||
        Input.trigger?(Input::B)
        @select = 2
        @oldx = @sprites["ball_#{@select}"].x
        @frame = 0
        pbPlayCursorSE
        @sprites["select"].visible = true
        @sprites["selection"].visible = true
        @sprites["select"].x = @x[@select]
        @sprites["select"].y = @y[@select]
        @sprites["selection"].x = @x[@select] - 28
        @sprites["selection"].y = @y[@select] - 154
        @sprites["select"].angle = 0
        pbChoosingScene
      end
    end
  end
 
  def pbChoosingScene
    @frameA = 0
    @framereset = 0
    @anim = 0
    while @endscene == 0
      pbUpdateSpriteHash(@sprites)
      Graphics.update
      Input.update
      pbAnimation
      if Input.trigger?(Input::RIGHT) && @select < 3
        @oldsel = @select
        @select += 1
        @oldx = @sprites["ball_#{@select}"].x
        @frame = 0
        pbPlayCursorSE
        @sprites["ball_1"].x = 102 if @oldsel == 1
        @sprites["ball_2"].x = 256 if @oldsel == 2
        @sprites["ball_3"].x = 410 if @oldsel == 3
        @sprites["ball_#{@oldsel}"].angle = 0
        @sprites["shadow_1"].x = 56 if @oldsel == 1
        @sprites["shadow_2"].x = 210 if @oldsel == 2
        @sprites["shadow_3"].x = 364 if @oldsel == 3
        @sprites["select"].x = @x[@select]
        @sprites["select"].y = @y[@select]
        @selframe = 0
        @sprites["selection"].y = @y[@select] - 154
        @sprites["selection"].x = @x[@select] - 28
        @sprites["select"].angle = 0
      end
      if Input.trigger?(Input::LEFT) && @select > 1
        @oldsel = @select
        @select -= 1
        @oldx = @sprites["ball_#{@select}"].x
        @frame = 0
        pbPlayCursorSE
        @sprites["ball_1"].x = 102 if @oldsel == 1
        @sprites["ball_2"].x = 256 if @oldsel == 2
        @sprites["ball_3"].x = 410 if @oldsel == 3
        @sprites["ball_#{@oldsel}"].angle = 0
        @sprites["shadow_1"].x = 56 if @oldsel == 1
        @sprites["shadow_2"].x = 210 if @oldsel == 2
        @sprites["shadow_3"].x = 364 if @oldsel == 3
        @sprites["select"].x = @x[@select]
        @sprites["select"].y = @y[@select]
        @selframe = 0
        @sprites["selection"].y = @y[@select] - 154
        @sprites["selection"].x = @x[@select] - 28
        @sprites["select"].angle = 0
      end
      if Input.trigger?(Input::C) || Input.trigger?(Input::A)
        @pokemon = @data["pkmn_#{@select}"]
        pokemon=[@pkmn1,@pkmn2,@pkmn3]
        @pkmn_array = pokemon
        pbPlayDecisionSE
        pbChooseBall
      end
    end
  end
 
  def pbChoiceBoxes(switch)
    # When switch is 0, it will turn on the boxes; when 1, it will turn off
    if switch == 0
      for i in 1..2
        @sprites["choice#{i}"].src_rect = Rect.new((i-1)*140,0,140,48)
        @sprites["choice#{i}"].visible = true
      end
      @sprites["choice1"].src_rect = Rect.new(0,48,140,48)
      @sprites["choicesel"].visible = true
      @sprites["choicesel"].opacity = 255
      @sprites["overlay"].visible = true
        pbDrawTextPositions(@overlay,[
          ["SÍ",442,184,2,Color.new(255,255,255),Color.new(74,74,74),true,Graphics.width],
          ["NO",442,230,2,Color.new(255,255,255),Color.new(74,74,74),true,Graphics.width]])
      @choicesel = 1
    else switch == 1
      for i in 1..2
        @sprites["choice#{i}"].src_rect = Rect.new((i-1)*140,0,140,48)
        @sprites["choice#{i}"].visible = false
      end
      @sprites["choicesel"].y = 174
      @sprites["choicesel"].visible = false
      @sprites["overlay"].visible = false
      @sel = nil
    end
  end
 
  def pbChooseBall
    # Organizing Type names and background colors
    case @pokemon.type1
    when PBTypes::NORMAL
      @type = "Normal"
      @sprites["typebg"].tone = Tone.new(95.25,88.5,63.0)
    when PBTypes::FIGHTING
      @type = "Lucha"
      @sprites["typebg"].tone = Tone.new(126.75,37.5,31.5)
    when PBTypes::FLYING
      @type = "Volador"
      @sprites["typebg"].tone = Tone.new(109.0,90.0,121.0)
    when PBTypes::POISON
      @type = "Veneno"
      @sprites["typebg"].tone = Tone.new(87.25,31.0,82.75)
    when PBTypes::GROUND
      @type = "Tierra"
      @sprites["typebg"].tone = Tone.new(108.0,91.0,43.0)
    when PBTypes::ROCK
      @type = "Roca"
      @sprites["typebg"].tone = Tone.new(83.0,74.0,28.0)
    when PBTypes::BUG
      @type = "Bicho"
      @sprites["typebg"].tone = Tone.new(90.0,108.0,2.0)
    when PBTypes::GHOST
      @type = "Fantasma"
      @sprites["typebg"].tone = Tone.new(58.55,43.0,95.25)
    when PBTypes::STEEL
      @type = "Acero"
      @sprites["typebg"].tone = Tone.new(79.5,79.5,79.5)
    when PBTypes::QMARKS
      @type = "???"
      @sprites["typebg"].tone = Tone.new(63.0,95.25,79.5)
    when PBTypes::FIRE
      @type = "Fuego"
      @sprites["typebg"].tone = Tone.new(169.0,93.0,42.0)
    when PBTypes::WATER
      @type = "Agua"
      @sprites["typebg"].tone = Tone.new(42.0,96.0,169.0)
    when PBTypes::GRASS
      @type = "Planta"
      @sprites["typebg"].tone = Tone.new(65.25,118.5,39.0)
    when PBTypes::ELECTRIC
      @type = "Electrico"
      @sprites["typebg"].tone = Tone.new(135.0,126.0,23.25)
    when PBTypes::PSYCHIC
      @type = "Psíquico"
      @sprites["typebg"].tone = Tone.new(128.25,51.75,96.0)
    when PBTypes::ICE
      @type = "Hielo"
      @sprites["typebg"].tone = Tone.new(55.5,102.75,102.75)
    when PBTypes::DRAGON
      @type = "Dragón"
      @sprites["typebg"].tone = Tone.new(54.75,43.5,114.75)
    when PBTypes::DARK
      @type = "Siniestro"
      @sprites["typebg"].tone = Tone.new(-23.0,-40.0,-56.0)
    when PBTypes::FAIRY
      @type = "Hada"
      @sprites["typebg"].tone = Tone.new(136.75,41.5,73.0)
    end
    @pkmnname = @pokemon.name
    @sprites["ballbase"].x = @x[@select]
    @sprites["ballbase"].y = @y[@select]
    @anim=0; @framereset=0; @frameA=0; zoom = STARTERCZ - 0.5 if STARTERCZ >= 1
    @sprites["select"].visible = false
    @sprites["selection"].visible = false
    20.times do
      pbUpdateSpriteHash(@sprites)
      pbAnimation if @frame < 16
      @sprites["typebg"].opacity += @sprites["starterbg"].opacity/18
      @sprites["ballbase"].opacity+=255/18
      @sprites["base"].opacity -= 105/10
      for i in 1..3
        @sprites["shadow_#{i}"].opacity -= 155/10
        @sprites["ball_#{i}"].opacity -= 105/10
      end
      pbWait(1)
    end
    20.times do
      pbUpdateSpriteHash(@sprites)
      @sprites["ballbase"].x += 154/20 if @select == 1
      @sprites["ballbase"].x -= 154/20 if @select == 3
      @sprites["base"].y += 40/20
      @sprites["ball_1"].y += 40/20
      @sprites["ball_2"].y += 40/20
      @sprites["ball_3"].y += 40/20
      @sprites["ballbase"].y -= 40/20
      @sprites["ballbase"].zoom_x += zoom/20 if STARTERCZ >= 1
      @sprites["ballbase"].zoom_y += zoom/20 if STARTERCZ >= 1
      pbWait(1)
    end
    2.times do
      pbUpdateSpriteHash(@sprites)
      @sprites["ballbase"].x += 6 if @select == 1
      @sprites["ballbase"].x -= 6 if @select == 3
      pbWait(1)
    end
    @sprites["ballbase"].x = @sprites["ball_2"].x if @select != 1
    10.times do
      pbUpdateSpriteHash(@sprites)
      @sprites["pkmn_#{@select}"].opacity += 255/10
      pbWait(1)
    end
    pbPlayCry(PBSpecies.const_get(@pkmn_array[@select-1].to_s.upcase))
    pbChoiceBoxes(0) # Turn on the choice boxes
    @sprites["textbox"].text = _INTL("<ac>¿Quieres a #{@pkmnname}, <br>del tipo #{@type}?</ac>")
    confirm = pbConfirm
if confirm == 1
  @sprites["textbox"].visible = false
  $game_variables[7] = @select if $game_variables[7] == 0
  
  # Guardar el nombre del Pokémon elegido en variable 52
  species_id = getID(PBSpecies, @pkmn_array[@select-1])
  $game_variables[52] = PBSpecies.getName(species_id)
  
  # Activar Self Switches según el starter elegido
  if @select == 1 && @event_id_1
    $game_self_switches[[@map_id, @event_id_1, "A"]] = true  # Pokéball izquierda
  elsif @select == 2 && @event_id_2
    $game_self_switches[[@map_id, @event_id_2, "A"]] = true  # Pokéball centro
  elsif @select == 3 && @event_id_3
    $game_self_switches[[@map_id, @event_id_3, "A"]] = true  # Pokéball derecha
  end
  
  @endscene = 1
  pbCloseScene
  pbAddPokemon(@pkmn_array[@select-1],STARTERL)
    else
      10.times do
        pbUpdateSpriteHash(@sprites)
        @sprites["pkmn_#{@select}"].opacity -= 255/10
        pbWait(1)
      end
      2.times do
        pbUpdateSpriteHash(@sprites)
        @sprites["ballbase"].x -= 6 if @select == 1
        @sprites["ballbase"].x += 6 if @select == 3
        pbWait(1)
      end
      20.times do
        pbUpdateSpriteHash(@sprites)
        @sprites["ballbase"].x -= 154/20 if @select == 1
        @sprites["ballbase"].x += 154/20 if @select == 3
        @sprites["base"].y -= 40/20
        @sprites["ball_1"].y -= 40/20
        @sprites["ball_2"].y -= 40/20
        @sprites["ball_3"].y -= 40/20
        @sprites["ballbase"].y += 40/20
        @sprites["ballbase"].zoom_x -= zoom/20 if STARTERCZ >= 1
        @sprites["ballbase"].zoom_y -= zoom/20 if STARTERCZ >= 1
        pbWait(1)
      end
      @sprites["ballbase"].x = @sprites["ball_#{@select}"].x if @select != 1
      @sprites["select"].visible = true
      @sprites["selection"].visible = true
      20.times do
        pbUpdateSpriteHash(@sprites)
        @sprites["typebg"].opacity -= @sprites["starterbg"].opacity/18
        @sprites["ballbase"].opacity-=255/18
        @sprites["base"].opacity += 105/10
        for i in 1..3
          @sprites["shadow_#{i}"].opacity += 155/10
          @sprites["ball_#{i}"].opacity += 105/10
        end
        pbWait(1)
      end
    end
  end
 
  def pbConfirm
    loop do
      intensity = (Graphics.frame_count%40)*12
      intensity = 480-intensity if intensity>240
      @sprites["choicesel"].opacity = intensity
      pbUpdateSpriteHash(@sprites)
      Graphics.update
      Input.update
      if Input.trigger?(Input::DOWN) && @choicesel != 2
        pbPlayCursorSE
        @choicesel += 1
        @sprites["choice1"].src_rect = Rect.new(0,0,140,48)
        @sprites["choice2"].src_rect = Rect.new(140,48,140,48)
        @sprites["choicesel"].y += 46
      end
      if Input.trigger?(Input::UP) && @choicesel != 1
        pbPlayCursorSE
        @choicesel -= 1
        @sprites["choice1"].src_rect = Rect.new(0,48,140,48)
        @sprites["choice2"].src_rect = Rect.new(140,0,140,48)
        @sprites["choicesel"].y -= 46
      end
      if Input.trigger?(Input::C) || Input.trigger?(Input::A) && @choicesel == 1
        pbChoiceBoxes(1) # Turn off the choice boxes
        @sprites["choicesel"].opacity = 255
        pbPlayDecisionSE
        return 1
      end
      if Input.trigger?(Input::B) || Input.trigger?(Input::C) && @choicesel == 2
        pbChoiceBoxes(1) # Turn off the choice boxes
        pbPlayCancelSE
        @sprites["choicesel"].opacity = 255
        return
      end
    end
  end
 
  def pbCloseScene
    @sprites["base"].visible = false
    @sprites["shadow_1"].visible = false
    @sprites["shadow_2"].visible = false
    @sprites["shadow_3"].visible = false
    @sprites["ball_1"].visible = false
    @sprites["ball_2"].visible = false
    @sprites["ball_3"].visible = false
    @sprites["select"].visible = false
    @sprites["selection"].visible = false
    25.times do
      @sprites["starterbg"].opacity -= 255/20
      @sprites["typebg"].opacity -= 255/20
      @sprites["ballbase"].opacity -= 255/20
      @sprites["pkmn_#{@select}"].opacity -= 255/20
      pbWait(1)
    end
    pbDisposeSpriteHash(@sprites) 
    @viewport.dispose   
  end
end
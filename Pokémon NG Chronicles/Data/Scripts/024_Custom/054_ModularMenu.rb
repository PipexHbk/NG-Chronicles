#===============================================================================
#  Neo PauseMenu
#    by Luka S.J.
# ---------------- 
#  Provides only features present in the default version of the Pokedex in
#  Essentials. Mean as a new cosmetic overhaul, adhering to the UI design
#  language of the Elite Battle System: The Next Generation
#
#  Enjoy the script, and make sure to give credit!
#  (DO NOT ALTER THE NAMES OF THE INDIVIDUAL SCRIPT SECTIONS OR YOU WILL BREAK
#   YOUR SYSTEM!)
#-------------------------------------------------------------------------------
#  Main module for handling each menu item/entry
=begin
Adding a new element (or entry) in your brand new Pause Menu could be likened to adding new item effects in your game. All the stuff you need is very self-contained, and there is no need to directly access any portions of the main script to add new stuff to your menu. Defining new elements in the pause menu however has some rules:

1.) Scroll to the very very bottom of the script. This is where you're going to define your new stuff. It has to be below the main module and the main classes of the script that handle the menu. Whatever order you define your menu elements in is the order they will appear on screen. So you can shuffle around between the currently existing element entries, but no further than that.

2.) Your icons for the menu elements are always going to be placed in 'Graphics/Icons/'

3.) For each menu element, you're going to have to define a symbolic name by which you'll handle it, the main string that will be displayed in the actual pause menu (for that element), the icon that you want displayed for that element, the block of code that the element is going to run once you select it in the menu, a block of code that will check whether or not the player has access to that element of the menu. The formal definition for this is as follows:



MenuHandlers.addEntry(:NAME,"Text displayed","icon name",proc{|menu|
# your lines of code go here
# keep in mind that the 'proc{|menu| ' part always has to be like this
# for every entry in your menu, when you go about defining the actual
# functionality that is run when the player selects that menu element
}
},proc{ # block of code that checks if the player has access to the menu element
# MUST ALWAYS return a boolean expression
# or if you want the player to always be able to trigger this:
return true
})
=end
#===============================================================================
module MenuHandlers
  # hash used to store the elements inside of the menu
  @@menuEntry = {}
  # hash used to store whether or not an element is unlocked
  @@available = {}
  # hash used to store the index of each element; for sorting
  @@indexes = {}
  @@index = 0
  # function to add a new element/entry to the menu.
  def self.addEntry(ref,name,icon,proc,conditional)
    @@menuEntry[ref] = [name,icon,proc]
    @@available[ref] = conditional
    @@indexes[ref] = @@index
    @@index += 1
  end
  # function to get the name of an element/entry
  def self.getName(ref)
    return @@menuEntry[ref][0]
  end
  # function to get the icon of an element/entry
  def self.getIcon(ref)
    return "Graphics/Icons/#{@@menuEntry[ref][1]}"
  end
  # function to get all the possible keys from the main hash
  def self.getKeys
    entries = Array.new(@@menuEntry.keys.length)
    for key in @@menuEntry.keys
      entries[@@indexes[key]] = key
    end
    return entries
  end
  # function used to invoke the stored code for each element/entry
  def self.runAction(ref,scene)
    @@menuEntry[ref][2].call(scene)
  end
  # function to check if the player has access to an element/entry
  def self.available?(ref)
    return @@available[ref].call
  end
  # function that lists all accessible menu elements/entries
  def self.elements?
    ent = self.getKeys
    items = 0
    for val in ent
      items += 1 if self.available?(val)
    end
    return items
  end
end
#-------------------------------------------------------------------------------
#  Compatibility for usage without the SJPlugins_Updater
#-------------------------------------------------------------------------------
class Sprite
 attr_reader :storedBitmap
  attr_accessor :speed
  attr_accessor :toggle
  attr_accessor :end_x
  attr_accessor :end_y
  attr_accessor :param
  attr_accessor :ex
  attr_accessor :ey

  def blur_sprite(blur_val=2,opacity=35)
    bitmap = self.bitmap
    self.bitmap = Bitmap.new(bitmap.width,bitmap.height)
    self.bitmap.blt(0,0,bitmap,Rect.new(0,0,bitmap.width,bitmap.height))
    x=0
    y=0
    for i in 1...(8 * blur_val)
      dir = i % 8
      x += (1 + (i / 8))*([0,6,7].include?(dir) ? -1 : 1)*([1,5].include?(dir) ? 0 : 1)
      y += (1 + (i / 8))*([1,4,5,6].include?(dir) ? -1 : 1)*([3,7].include?(dir) ? 0 : 1)
      self.bitmap.blt(x-blur_val,y+(blur_val*2),bitmap,Rect.new(0,0,bitmap.width,bitmap.height),opacity)
    end
  end
end

class ScrollingSprite < Sprite
  attr_accessor :speed
  attr_accessor :direction
  attr_accessor :vertical
  
  def setBitmap(val,vertical=false,pulse=false)
    @vertical = vertical
    @pulse = pulse
    @direction = 1 if @direction.nil?
    @gopac = 1
    @speed = 32 if @speed.nil?
    val = pbBitmap(val) if val.is_a?(String)
    if @vertical
      bmp = Bitmap.new(val.width,val.height*2)
      for i in 0...2
        bmp.blt(0,val.height*i,val,Rect.new(0,0,val.width,val.height))
      end
      self.bitmap = bmp.clone
      y = @direction > 0 ? 0 : val.height
      self.src_rect.set(0,y,val.width,val.height)
    else
      bmp = Bitmap.new(val.width*2,val.height)
      for i in 0...2
        bmp.blt(val.width*i,0,val,Rect.new(0,0,val.width,val.height))
      end
      self.bitmap = bmp.clone
      x = @direction > 0 ? 0 : val.width
      self.src_rect.set(x,0,val.width,val.height)
    end
  end
  
  def update
    if @vertical
      self.src_rect.y += @speed*@direction
      self.src_rect.y = 0 if @direction > 0 && self.src_rect.y >= self.src_rect.height
      self.src_rect.y = self.src_rect.height if @direction < 0 && self.src_rect.y <= 0
    else
      self.src_rect.x += @speed*@direction
      self.src_rect.x = 0 if @direction > 0 && self.src_rect.x >= self.src_rect.width
      self.src_rect.x = self.src_rect.width if @direction < 0 && self.src_rect.x <= 0
    end
    if @pulse
      self.opacity -= @gopac*@speed
      @gopac *= -1 if self.opacity == 255 || self.opacity == 0
    end
  end
    
end

def pbBitmap(name)
  if !pbResolveBitmap(name).nil?
    bmp = BitmapCache.load_bitmap(name)
  else
    p "Image located at '#{name}' was not found!" if $DEBUG
    bmp = Bitmap.new(1,1)
  end
  return bmp
end
#-------------------------------------------------------------------------------
#  Main class used to handle the visuals
#-------------------------------------------------------------------------------
class PokemonMenu_Scene
  attr_accessor :index
  attr_accessor :entries
  attr_accessor :endscene
  attr_accessor :close
  attr_accessor :hidden
  
  # retained for compatibility
  def pbShowInfo(text)
    @sprites["helpwindow"].resizeToFit(text,Graphics.height)
    @sprites["helpwindow"].text = text
    @sprites["helpwindow"].visible = true
    @helpstate = true
    pbBottomLeft(@sprites["helpwindow"])
  end
  # retained for compatibility
  def pbShowHelp(text)
    @sprites["helpwindow"].resizeToFit(text,Graphics.height)
    @sprites["helpwindow"].text = text
    @sprites["helpwindow"].visible = true
    @helpstate = true
    pbBottomLeft(@sprites["helpwindow"])
  end
  # main scene generation
  def pbStartScene
    # sets the default index
    @index = $PokemonTemp.menuLastChoice.nil? ? 0 : $PokemonTemp.menuLastChoice
    @index = 0 if @index >= MenuHandlers.elements?
    @oldindex = 0
    @endscene = true
    @close = false
    @hidden = false
    # loads the visual parts of the 
    @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z = 99999
    @sprites = {}
    # initializes the background graphic
    @sprites["background"] = Sprite.new(@viewport)
    @sprites["background"].bitmap = Graphics.snap_to_bitmap
    @sprites["background"].blur_sprite(3)
    @sprites["background"].bitmap.blt(0,0,pbBitmap("Graphics/Pictures/PauseMenu/bg"),Rect.new(0,0,Graphics.width,Graphics.height))
    bmp = pbBitmap("Graphics/Pictures/Common/scrollbar_bg")
    @sprites["background"].bitmap.blt(Graphics.width - 28,(Graphics.height - bmp.height)/2,bmp,Rect.new(0,0,bmp.width,bmp.height))
    # initializes the scrolling panorama
    @sprites["panorama"] = ScrollingSprite.new(@viewport)
    @sprites["panorama"].setBitmap("Graphics/Pictures/Common/panorama")
    @sprites["panorama"].speed = 1
    # retained for compatibility
    @sprites["infowindow"] = Window_UnformattedTextPokemon.newWithSize("",0,0,32,32,@viewport)
    @sprites["infowindow"].visible = false
    @sprites["helpwindow"] = Window_UnformattedTextPokemon.newWithSize("",0,0,32,32,@viewport)
    @sprites["helpwindow"].visible = false
    # initializes the scroll bar
    @sprites["scroll"] = Sprite.new(@viewport)
    # rendering elements on screen
    self.refresh
    self.update
    # memorizes the target opacities and sets them to 0
    @opacities = {}
    for key in @sprites.keys
      @opacities[key] = @sprites[key].opacity
      @sprites[key].opacity = 0
    end
  end

  def pbHideMenu
    # animations for closing the menu
    8.times do
      for key in @sprites.keys
        next if !@sprites[key] || @sprites[key].disposed?
        @sprites[key].opacity -= 32
      end
      Graphics.update
    end
  end

def pbShowMenu
  # animations for opening the menu (robusto frente a @opacities faltantes)
  8.times do
    for key in @sprites.keys
      s = @sprites[key]
      next if !s || s.disposed?
      target = (@opacities && @opacities[key]) ? @opacities[key] : s.opacity
      # si target no es numérico, asignar 255 por defecto
      target = 255 unless target.is_a?(Numeric)
      s.opacity += 32 if s.opacity < target
    end
    Graphics.update
  end
end

  
  def refresh
    # index safety
    @index = MenuHandlers.elements? - 1 if @index >= MenuHandlers.elements?
    @oldindex = @index
    # disposes old items in the menu
    if @entries
      for i in 0...@entries.length
        @sprites["#{i}"].dispose if @sprites["#{i}"]
      end
    end
    # creates a new list of available items
    ent = MenuHandlers.getKeys
    @entries = []
    for val in ent
      @entries.push(val) if MenuHandlers.available?(val)
    end
    # draws individual item entries
    bmp = pbBitmap("Graphics/Pictures/PauseMenu/sel")
    for i in 0...@entries.length
      key = @entries[i]
      @sprites["#{i}"] = Sprite.new(@viewport)
      @sprites["#{i}"].bitmap = Bitmap.new(bmp.width,bmp.height)
      pbSetSystemFont(@sprites["#{i}"].bitmap)
      @sprites["#{i}"].src_rect.set(0,0,bmp.width/2,bmp.height)
      @sprites["#{i}"].bitmap.blt(0,0,bmp,Rect.new(0,0,bmp.width,bmp.height))
      for j in 0...2
        opac = j == 0 ? 155 : 255
        icon = pbBitmap(MenuHandlers.getIcon(key))
        text = MenuHandlers.getName(key)
        text.gsub!("\\pn"){"#{$Trainer.name}"}
        @sprites["#{i}"].bitmap.blt(18 + j*bmp.width/2,6,icon,Rect.new(0,0,48,48),opac)
        pbDrawOutlineText(@sprites["#{i}"].bitmap,66 + j*bmp.width/2,6,136,48,text,Color.new(255,255,255),Color.new(64,64,64),1)
      end
      @sprites["#{i}"].x = Graphics.width - bmp.width/2 - 52
      @sprites["#{i}"].y = 49 + (bmp.height + 12)*i
      @sprites["#{i}"].opacity = 128
    end
    # configures the scroll bar
    n = (@entries.length < 4 ? 1 : @entries.length - 3)
    height = 204/n
    height += 204 - (height*n)
    height += 16
    @sprites["scroll"].bitmap = Bitmap.new(16,height)
    bmp = pbBitmap("Graphics/Pictures/Common/scrollbar_kn")
    @sprites["scroll"].bitmap.blt(0,0,bmp,Rect.new(0,0,16,6))
    @sprites["scroll"].bitmap.stretch_blt(Rect.new(0,6,16,height-14),bmp,Rect.new(0,6,16,1))
    @sprites["scroll"].bitmap.blt(0,height-8,bmp,Rect.new(0,8,16,8))
    @sprites["scroll"].x = Graphics.width - 32
    @sprites["scroll"].y = (Graphics.height - 204)/2
    @sprites["scroll"].end_y = (Graphics.height - 204)/2
  end
  
  def update
    # scrolling background image
    @sprites["panorama"].update
    # calculations for updating the scrollbar position
    k = (@entries.length < 4 ? 0 : @index - 3)
    k = 0 if k < 0
    n = (@entries.length < 4 ? 1 : @entries.length - 3)
    height = 204/n
    @sprites["scroll"].end_y = (Graphics.height-204)/2 + height*k
    @sprites["scroll"].y += (@sprites["scroll"].end_y - @sprites["scroll"].y)*0.2
    # updates for each element/entry in the menu
    for i in 0...@entries.length
      j = @entries.length < 4 ? 0 : (@index - 3)
      j = 0 if j < 0
      y = (-j)*(@sprites["#{i}"].src_rect.height + 12) + 49 + i*(@sprites["#{i}"].src_rect.height + 12)
      @sprites["#{i}"].y -= (@sprites["#{i}"].y - y)*0.1
      @sprites["#{i}"].src_rect.x = @sprites["#{i}"].src_rect.width*(@index == i ? 1 : 0)
      @sprites["#{i}"].x += 2 if @sprites["#{i}"].x < Graphics.width - @sprites["#{i}"].src_rect.width - 52
      if i.between?(j,j+3)
        @sprites["#{i}"].opacity += 15 if @sprites["#{i}"].opacity < 255
      else
        @sprites["#{i}"].opacity -= 15 if @sprites["#{i}"].opacity > 128
      end
      if @index == i
        @sprites["#{i}"].tone.gray -= 51 if @sprites["#{i}"].tone.gray > 0
      else
        @sprites["#{i}"].tone.gray += 51 if @sprites["#{i}"].tone.gray < 255
      end
    end
    # sets the index
    if @oldindex != @index
      @sprites["#{@index}"].x -= 6
      @oldindex = @index
    end
  end

  def pbEndScene
    # disposes the sprite hash
    pbHideMenu
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end

  def pbRefresh
  end
end
#-------------------------------------------------------------------------------
#  Main class used to handle the logic of the pause menu
#-------------------------------------------------------------------------------
class PokemonMenu
  def initialize(scene)
    @scene = scene
  end

  def pbShowMenu
    #@scene.pbRefresh
    @scene.pbShowMenu
  end

  def pbStartPokemonMenu
    pbSEPlay("SE_Select2")
    # loads up the scene
    @scene.pbStartScene
    @scene.pbShowMenu
    loop do
      # main loop
      Graphics.update
      Input.update
      @scene.update
      if Input.repeat?(Input::DOWN)
        @scene.index += 1
        @scene.index = 0 if @scene.index > @scene.entries.length - 1
        $PokemonTemp.menuLastChoice = @scene.index
        pbSEPlay("SE_Select1")
      elsif Input.repeat?(Input::UP)
        @scene.index -= 1
        @scene.index = @scene.entries.length - 1 if @scene.index < 0
        $PokemonTemp.menuLastChoice = @scene.index
        pbSEPlay("SE_Select1")
      elsif Input.trigger?(Input::C) || Input.trigger?(Input::A)
        pbSEPlay("SE_Select2")
        MenuHandlers.runAction(@scene.entries[@scene.index],@scene)
      end
      break if @scene.close || Input.trigger?(Input::B)
    end
    # used to dispose of the scene
    @scene.pbEndScene if @scene.endscene
  end  
end
#-------------------------------------------------------------------------------
#  Your own entries for the pause menu
#
#  How to use
#
#  MenuHandlers.addEntry(:name,"button text","icon name",proc{|menu|
#    # code you want to run
#    # when the entry in the menu is selected
#  },proc{ # code to check if menu entry is available })
#-------------------------------------------------------------------------------
# PokeDex
MenuHandlers.addEntry(:POKEDEX,"Pokédex","menuPokedex",proc{|menu|
  # Asegurarse de que pokedexViable esté inicializado
  pbSetViableDexes if !$PokemonGlobal.pokedexViable || $PokemonGlobal.pokedexViable.length == 0
  
  if $PokemonGlobal.pokedexViable && $PokemonGlobal.pokedexViable.length==1
    $PokemonGlobal.pokedexDex = $PokemonGlobal.pokedexViable[0]
    $PokemonGlobal.pokedexDex = -1 if $PokemonGlobal.pokedexDex == $PokemonGlobal.pokedexUnlocked.length - 1
    pbFadeOutIn(99999) {
      scene = PokemonPokedexScene.new
      screen = PokemonPokedex.new(scene)
      screen.pbStartScreen
    }
  else
    pbLoadRpgxpScene(Scene_PokedexMenu.new)
  end
},proc{ 
  return false if !$Trainer
  return false if !$Trainer.pokedex
  pbSetViableDexes if !$PokemonGlobal.pokedexViable || $PokemonGlobal.pokedexViable.length == 0
  return true
})
# Party Screen
MenuHandlers.addEntry(:POKEMON,"Pokémon","menuPokemon",proc{|menu|
  sscene = PokemonScreen_Scene.new
  sscreen = PokemonScreen.new(sscene,$Trainer.party)
  hiddenmove = nil
  pbFadeOutIn(99999) { 
    hiddenmove = sscreen.pbPokemonScreen
    if hiddenmove
      menu.pbEndScene
      menu.endscene = false
    end
  }
  if hiddenmove
    Kernel.pbUseHiddenMove(hiddenmove[0],hiddenmove[1])
    menu.close = true
  end
},proc{ return $Trainer.party.length > 0 })
# Bag Screen
MenuHandlers.addEntry(:BAG,"Mochila","menuBag",proc{|menu|
  item = 0
  scene = PokemonBag_Scene.new
  screen = PokemonBagScreen.new(scene,$PokemonBag)
  pbFadeOutIn(99999) { 
  item = screen.pbStartScreen 
  if item > 0
    menu.pbEndScene
    menu.endscene = false
  end
  }
  if item > 0
    Kernel.pbUseKeyItemInField(item)
    menu.close = true
  end
},proc{ return true })
# PokeGear
MenuHandlers.addEntry(:POKEGEAR,"Pokégear","menuPokegear",proc{|menu|
  pbLoadRpgxpScene(Scene_Pokegear.new)
},proc{ return $Trainer.pokegear })
# Trainer Card
MenuHandlers.addEntry(:TRAINER,"\\pn","menuTrainer",proc{|menu|
  scene = PokemonTrainerCardScene.new
  screen = PokemonTrainerCard.new(scene)
  pbFadeOutIn(99999) { 
    screen.pbStartScreen
  }
},proc{ return true })
# Save Screen
MenuHandlers.addEntry(:SAVE,"Guardar","menuSave",proc{|menu|
  scene = PokemonSaveScene.new
  screen = PokemonSave.new(scene)
  if screen.pbSaveScreen
    menu.pbEndScene
    menu.endscene = false
    menu.close = true
  end
},proc{ return true })
# Options Screen
MenuHandlers.addEntry(:OPTIONS,"Opciones","menuOptions",proc{|menu|
  scene = PokemonOptionScene.new
  screen = PokemonOption.new(scene)
  pbFadeOutIn(99999) {
    screen.pbStartScreen
    pbUpdateSceneMap
  }
},proc{ return true })
# Debug Menu
MenuHandlers.addEntry(:DEBUG,"Debug","menuDebug",proc{|menu|
  pbFadeOutIn(99999) { 
    pbDebugMenu
    menu.refresh
  }
},proc{ return $DEBUG })

# Salir del Juego
MenuHandlers.addEntry(:QUIT, "Salir del Juego", "menuQuit", proc { |menu|
  pbPlayDecisionSE
  menu.pbHideMenu
  if Kernel.pbConfirmMessage(_INTL("¿Quieres salir del juego?"))
    # Abrir la escena de guardado usando la convención del resto del menú
    scene = PokemonSaveScene.new
    screen = PokemonSave.new(scene)
    if screen.pbSaveScreen
      Kernel.pbMessage(_INTL("La partida ha sido guardada."))
      # Espera breve (~2.5 s) manteniendo el motor actualizado
      target = Graphics.frame_count + 150
      while Graphics.frame_count < target
        Graphics.update
        Input.update
      end
      # Señalamos al controlador que cierre la escena fuera del loop
      menu.endscene = true if menu.respond_to?(:endscene=)
      menu.close = true if menu.respond_to?(:close=)
      # Indicamos salida de la aplicación (igual que otras versiones del script)
      $scene = nil
      next
    else
      # Si el guardado fue cancelado/falló, volver al menú
      menu.pbRefresh if menu.respond_to?(:pbRefresh)
      menu.pbShowMenu if menu.respond_to?(:pbShowMenu)
      next
    end
  else
    # Usuario canceló la confirmación: volver al menú
    menu.pbRefresh if menu.respond_to?(:pbRefresh)
    menu.pbShowMenu if menu.respond_to?(:pbShowMenu)
    next
  end
}, proc { return true })

      
# --- Panel Izquierdo con información útil ---

class PokemonMenu_Scene
  alias __nm_wide_final_pbStartScene pbStartScene
  def pbStartScene
    __nm_wide_final_pbStartScene
    begin
      # Layout: mayor ancho pero sin solapar la lista de la derecha
      @__nm_panel_width = 220
      @__nm_panel_x = 8
      @__nm_panel_y = 6
      panel_h = Graphics.height - 12

      # fondo izquierdo
      @sprites["left_panel_bg"] ||= Sprite.new(@viewport)
      if !@sprites["left_panel_bg"].bitmap || @sprites["left_panel_bg"].bitmap.width != @__nm_panel_width || @sprites["left_panel_bg"].bitmap.height != panel_h
        @sprites["left_panel_bg"].bitmap.dispose rescue nil
        @sprites["left_panel_bg"].bitmap = Bitmap.new(@__nm_panel_width, panel_h)
        @sprites["left_panel_bg"].bitmap.fill_rect(0, 0, @__nm_panel_width, panel_h, Color.new(0,0,0,150))
        @sprites["left_panel_bg"].x = @__nm_panel_x
        @sprites["left_panel_bg"].y = @__nm_panel_y
        @sprites["left_panel_bg"].opacity = 220
      end

      # reloj
      clock_w = @__nm_panel_width - 28
      clock_h = 48
      @sprites["left_clock"] ||= Sprite.new(@viewport)
      if !@sprites["left_clock"].bitmap || @sprites["left_clock"].bitmap.width != clock_w || @sprites["left_clock"].bitmap.height != clock_h
        @sprites["left_clock"].bitmap.dispose rescue nil
        @sprites["left_clock"].bitmap = Bitmap.new(clock_w, clock_h)
      end
      @sprites["left_clock"].x = @sprites["left_panel_bg"].x + 14
      @sprites["left_clock"].y = @sprites["left_panel_bg"].y + 10

      # Crear sprites ANIMADOS para cada Pokémon
      for i in 0...6
        @sprites["party_icon_#{i}"] ||= PokemonIconSprite.new(nil, @viewport)
        @sprites["party_icon_#{i}"].z = 99999
      end

      # Contenedor para barras de HP y estado
      @sprites["team_container"] ||= Sprite.new(@viewport)
      team_w = @__nm_panel_width - 28
      team_h = panel_h - (clock_h + 34)
      team_h = 220 if team_h < 220
      if !@sprites["team_container"].bitmap || @sprites["team_container"].bitmap.width != team_w || @sprites["team_container"].bitmap.height != team_h
        @sprites["team_container"].bitmap.dispose rescue nil
        @sprites["team_container"].bitmap = Bitmap.new(team_w, team_h)
        @sprites["team_container"].x = @sprites["left_panel_bg"].x + 14
        @sprites["team_container"].y = @sprites["left_clock"].y + clock_h + 14
      else
        @sprites["team_container"].x = @sprites["left_panel_bg"].x + 14
        @sprites["team_container"].y = @sprites["left_clock"].y + clock_h + 14
      end

      # dibujado inicial
      draw_clock_wide_final rescue nil
      draw_team_container_wide_final rescue nil
    rescue
    end
  end

  alias __nm_wide_final_refresh refresh
  def refresh
    __nm_wide_final_refresh
    begin
      draw_team_container_wide_final
    rescue
    end
  end

  alias __nm_wide_final_update update
  def update
    __nm_wide_final_update
    begin
      draw_clock_wide_final rescue nil
      # Animar los íconos del equipo
      for i in 0...6
        @sprites["party_icon_#{i}"].update if @sprites["party_icon_#{i}"]
      end
      draw_team_container_wide_final if Graphics.frame_count % 8 == 0
    rescue
    end
  end

  alias __nm_wide_final_pbEndScene pbEndScene
  def pbEndScene
    __nm_wide_final_pbEndScene
    begin
      ["left_panel_bg","left_clock","team_container"].each do |k|
        if @sprites && @sprites[k] && @sprites[k].bitmap
          @sprites[k].bitmap.dispose rescue nil
        end
      end
      # Limpiar sprites de íconos
      for i in 0...6
        @sprites["party_icon_#{i}"].dispose rescue nil if @sprites["party_icon_#{i}"]
      end
    rescue
    end
  end

  def draw_clock_wide_final
    return if !@sprites || !@sprites["left_clock"] || !@sprites["left_clock"].bitmap
    bmp = @sprites["left_clock"].bitmap
    bmp.clear
    pbSetSystemFont(bmp)
    t = Time.now
    date_str = t.strftime("%d/%m/%Y")
    time_str = t.strftime("%H:%M:%S")
    left_margin = 8
    right_margin = 12
    usable_w = [bmp.width - left_margin - right_margin, 40].max
    pbDrawOutlineText(bmp, left_margin, 0, usable_w, 20, date_str, Color.new(245,245,245), Color.new(0,0,0), 1)
    pbDrawOutlineText(bmp, left_margin, 22, usable_w, 20, time_str, Color.new(200,230,255), Color.new(0,0,0), 1)
  end

  def draw_team_container_wide_final
    return if !@sprites || !@sprites["team_container"] || !@sprites["team_container"].bitmap
    bmp = @sprites["team_container"].bitmap
    bmp.clear
    pbSetSystemFont(bmp)
    party = $Trainer.party rescue []
    cols = 2
    rows = 3
    cell_h = (bmp.height.to_f / rows).floor
    col_w = (bmp.width.to_f / cols).floor
    
    icon_size = 64
    bar_h = 8
    bar_margin_top = 4
    bar_w = [col_w - 18, 44].max
    
    for i in 0...6
      col = i % cols
      row = i / cols
      cell_x = col * col_w
      cell_y = row * cell_h
      center_x = cell_x + (col_w / 2)
      
      icon_x = center_x - (icon_size / 2)
      icon_y = cell_y + 4
      
      if party[i]
        pkm = party[i]
        
        # Configurar el sprite animado del ícono
        icon_sprite = @sprites["party_icon_#{i}"]
        if icon_sprite
          icon_sprite.pokemon = pkm  # Esto configura la especie Y la forma automáticamente
          icon_sprite.x = @sprites["team_container"].x + icon_x
          icon_sprite.y = @sprites["team_container"].y + icon_y
          icon_sprite.visible = true
        end
        
        # Barra de HP
        bar_x = center_x - (bar_w / 2)
        bar_y = icon_y + icon_size + bar_margin_top
        bar_y = [bar_y, cell_y + cell_h - bar_h - 14].min
        
        bmp.fill_rect(bar_x, bar_y, bar_w, bar_h, Color.new(40,40,40))
        
        curhp = pkm.hp rescue 0
        tothp = (pkm.totalhp rescue 1)
        fill_w = ((curhp.to_f / [tothp,1].max) * bar_w).to_i
        pct = curhp.to_f / [tothp,1].max
        fill_col = pct > 0.5 ? Color.new(64,192,80) : (pct > 0.2 ? Color.new(240,192,48) : Color.new(224,64,64))
        bmp.fill_rect(bar_x, bar_y, fill_w, bar_h, fill_col)
        
        # Estado del Pokémon
        status_text = ""
        st = pkm.status rescue 0
        
        if pkm.hp <= 0
          status_text = "Debilitado"
          status_col = Color.new(120,120,120)
        elsif st == PBStatuses::POISON
          status_text = "Envenenado"
          status_col = Color.new(160,64,160)
        elsif st == PBStatuses::BURN
          status_text = "Quemado"
          status_col = Color.new(240,128,48)
        elsif st == PBStatuses::PARALYSIS
          status_text = "Paralizado"
          status_col = Color.new(248,208,48)
        elsif st == PBStatuses::SLEEP
          status_text = "Dormido"
          status_col = Color.new(120,120,120)
        elsif st == PBStatuses::FROZEN
          status_text = "Congelado"
          status_col = Color.new(96,208,224)
        else
          status_text = ""
          status_col = Color.new(255,255,255)
        end
        
        if status_text && status_text != ""
          # Reducir tamaño de fuente y subir el texto
          old_font_size = bmp.font.size
          bmp.font.size = 20  # ← Tamaño fuente/Pequeño:Bajar N° - Grande:Subir N°
          
          text_y = bar_y - 0  # ← Pos. Vertical/Subir:Bajar N° - Bajar:Subir N°
          text_w = col_w - 8
          text_x = cell_x + 4 # ← Pos. Horizontal/Izq.:Bajar N° - Der.:Subir N°
          
          pbDrawShadowText(bmp, text_x, text_y, text_w, 12, status_text, status_col, Color.new(0,0,0),1)
          
          bmp.font.size = old_font_size  # Restaurar tamaño original
        end
        
      else
        # Slot vacío - ocultar el sprite del ícono
        icon_sprite = @sprites["party_icon_#{i}"]
        if icon_sprite
          icon_sprite.pokemon = nil
          icon_sprite.visible = false
        end
        
        # Dibujar pokéball vacía estática
        icon = pbBitmap("Graphics/Icons/pokeball")
        ix = icon_x
        iy = icon_y
        
        ix = [[ix, 0].max, bmp.width - icon_size].min
        iy = [[iy, 0].max, bmp.height - icon_size - bar_h - 16].min
        
        begin
          icon_frame_width = icon.height
          if icon.width > icon.height
            icon_frame_width = icon.height
          else
            icon_frame_width = icon.width
          end
          
          bmp.blt(
            ix, iy, 
            icon, 
            Rect.new(0, 0, icon_frame_width, icon.height), 
            80
          )
        rescue
          bmp.fill_rect(ix, iy, icon_size, icon_size, Color.new(50,50,50))
        end
      end
    end
  end
end
################################################################################
# MÓDULO: Save Slots Manager
# Gestiona los 5 slots de guardado
################################################################################
module SaveSlotsManager
  TOTAL_SLOTS = 5
  SLOT_CONFIG_FILE = "Data/slot_config.dat"

  def self.getActiveSlot
    if safeExists?(SLOT_CONFIG_FILE)
      begin
        active = nil
        File.open(SLOT_CONFIG_FILE, 'rb') { |f| active = Marshal.load(f) }
        if active.is_a?(Numeric) && active > 0 && active <= TOTAL_SLOTS
          return active
        end
      rescue
      end
    end
    return 1
  end

  def self.setActiveSlot(slot_number)
    return false if !slot_number.is_a?(Numeric) || slot_number < 1 || slot_number > TOTAL_SLOTS
    begin
      File.open(SLOT_CONFIG_FILE, 'wb') { |f| Marshal.dump(slot_number, f) }
      return true
    rescue
      return false
    end
  end

  def self.getSaveFileName(slot_number = nil)
    slot_number ||= getActiveSlot
    if slot_number.nil? || slot_number < 1
      slot_number = 1
    end
    return RTP.getSaveFileName("Game_Slot#{slot_number}.rxdata")
  end

  def self.slotExists?(slot_number)
    return safeExists?(getSaveFileName(slot_number))
  end

  def self.getSlotInfo(slot_number)
    savefile = getSaveFileName(slot_number)
    return nil unless safeExists?(savefile)
    
    begin
      trainer = nil
      framecount = nil
      mapid = nil
      File.open(savefile) { |f|
        trainer = Marshal.load(f)
        framecount = Marshal.load(f)
        Marshal.load(f)
        Marshal.load(f)
        mapid = Marshal.load(f)
      }
      return [trainer, framecount, mapid]
    rescue
      return nil
    end
  end

  def self.deleteSlot(slot_number)
    return false if !slot_number.is_a?(Numeric) || slot_number < 1 || slot_number > TOTAL_SLOTS
    savefile = getSaveFileName(slot_number)
    begin
      File.delete(savefile) if safeExists?(savefile)
      File.delete(savefile + ".bak") if safeExists?(savefile + ".bak")
      return true
    rescue
      return false
    end
  end
end

class PokemonLoadPanel < SpriteWrapper
  attr_reader :selected

  def initialize(index,title,isContinue,trainer,framecount,mapid,viewport=nil)
    super(viewport)
    @index=index
    @title=title
    @isContinue=isContinue
    @trainer=trainer
    @totalsec=(framecount || 0)/Graphics.frame_rate
    @mapid=mapid
    @selected=(index==0)
    @bgbitmap=AnimatedBitmap.new("Graphics/Pictures/loadPanels")
    @refreshBitmap=true
    @refreshing=false 
    refresh
  end

  def dispose
    @bgbitmap.dispose
    self.bitmap.dispose
    super
  end

  def selected=(value)
    if @selected!=value
      @selected=value
      @refreshBitmap=true
      refresh
    end
  end

  def pbRefresh
    @refreshBitmap=true
    refresh
  end

  def refresh
    return if @refreshing
    return if disposed?
    @refreshing=true
    if !self.bitmap || self.bitmap.disposed?
      self.bitmap=BitmapWrapper.new(@bgbitmap.width,111*2)
      pbSetSystemFont(self.bitmap)
    end
    if @refreshBitmap
      @refreshBitmap=false
      self.bitmap.clear if self.bitmap
      if @isContinue
        self.bitmap.blt(0,0,@bgbitmap.bitmap,
           Rect.new(0,(@selected ? 111*2 : 0),@bgbitmap.width,111*2))
      else
        self.bitmap.blt(0,0,@bgbitmap.bitmap,
           Rect.new(0,111*2*2+(@selected ? 23*2 : 0),@bgbitmap.width,23*2))
      end
      textpos=[]
      if @isContinue
        textpos.push([@title,16*2,5*2,0,Color.new(232,232,232),Color.new(136,136,136)])
        textpos.push([_INTL("Medallas:"),16*2,56*2,0,Color.new(232,232,232),Color.new(136,136,136)])
        textpos.push([@trainer.numbadges.to_s,103*2,56*2,1,Color.new(232,232,232),Color.new(136,136,136)])
        textpos.push([_INTL("Pokédex:"),16*2,72*2,0,Color.new(232,232,232),Color.new(136,136,136)])
        textpos.push([@trainer.pokedexSeen.to_s,103*2,72*2,1,Color.new(232,232,232),Color.new(136,136,136)])
        textpos.push([_INTL("Tiempo:"),16*2,88*2,0,Color.new(232,232,232),Color.new(136,136,136)])
        hour = @totalsec / 60 / 60
        min = @totalsec / 60 % 60
        if hour>0
          textpos.push([_INTL("{1}h {2}m",hour,min),103*2,88*2,1,Color.new(232,232,232),Color.new(136,136,136)])
        else
          textpos.push([_INTL("{1}m",min),103*2,88*2,1,Color.new(232,232,232),Color.new(136,136,136)])
        end
        if @trainer.isMale?
          textpos.push([@trainer.name,56*2,32*2,0,Color.new(56,160,248),Color.new(56,104,168)])
        else
          textpos.push([@trainer.name,56*2,32*2,0,Color.new(240,72,88),Color.new(160,64,64)])
        end
        mapname=pbGetMapNameFromId(@mapid)
        mapname.gsub!(/\\PN/,@trainer.name)
        textpos.push([mapname,193*2,5*2,1,Color.new(232,232,232),Color.new(136,136,136)])
      else
        textpos.push([@title,16*2,4*2,0,Color.new(232,232,232),Color.new(136,136,136)])
      end
      pbDrawTextPositions(self.bitmap,textpos)
    end
    @refreshing=false
  end
end

class PokemonLoadScene
  def pbUpdate
    oldi=@sprites["cmdwindow"].index rescue 0
    pbUpdateSpriteHash(@sprites)
    newi=@sprites["cmdwindow"].index rescue 0
    if oldi!=newi
      @sprites["panel#{oldi}"].selected=false
      @sprites["panel#{oldi}"].pbRefresh
      @sprites["panel#{newi}"].selected=true
      @sprites["panel#{newi}"].pbRefresh
      while @sprites["panel#{newi}"].y>Graphics.height-16*2-23*2-1*2
        for i in 0...@commands.length
          @sprites["panel#{i}"].y-=23*2+1*2
        end
        for i in 0...6
          break if !@sprites["party#{i}"]
          @sprites["party#{i}"].y-=23*2+1*2
        end
        @sprites["player"].y-=23*2+1*2 if @sprites["player"]
      end
      while @sprites["panel#{newi}"].y<16*2
        for i in 0...@commands.length
          @sprites["panel#{i}"].y+=23*2+1*2
        end
        for i in 0...6
          break if !@sprites["party#{i}"]
          @sprites["party#{i}"].y+=23*2+1*2
        end
        @sprites["player"].y+=23*2+1*2 if @sprites["player"]
      end
    end
  end

  def pbStartScene(commands,showContinue,trainer,framecount,mapid)
    @commands=commands
    @sprites={}
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99998
    addBackgroundOrColoredPlane(@sprites,"background","loadbg",
       Color.new(248,248,248),@viewport)
    y=16*2
    for i in 0...commands.length
      @sprites["panel#{i}"]=PokemonLoadPanel.new(i,commands[i],
         (showContinue ? (i==0) : false),trainer,framecount,mapid,@viewport)
      @sprites["panel#{i}"].pbRefresh
      @sprites["panel#{i}"].x=24*2
      @sprites["panel#{i}"].y=y
      y+=(showContinue && i==0) ? 111*2+1*2 : 23*2+1*2
    end
    @sprites["cmdwindow"]=Window_CommandPokemon.new([])
    @sprites["cmdwindow"].x=Graphics.width
    @sprites["cmdwindow"].y=0
    @sprites["cmdwindow"].viewport=@viewport
    @sprites["cmdwindow"].visible=false
  end

  def pbStartScene2
    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def pbStartDeleteScene
    @sprites={}
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99998
    addBackgroundOrColoredPlane(@sprites,"background","loadbg",
       Color.new(248,248,248),@viewport)
  end

  def pbSetParty(trainer)
    return if !trainer || !trainer.party
    meta=pbGetMetadata(0,MetadataPlayerA+trainer.metaID)
    if meta
      filename=pbGetPlayerCharset(meta,1,trainer)
      @sprites["player"]=TrainerWalkingCharSprite.new(filename,@viewport)
      charwidth=@sprites["player"].bitmap.width
      charheight=@sprites["player"].bitmap.height
      @sprites["player"].x = 56*2 - charwidth/8
      @sprites["player"].y = 56*2 - charheight/8
      @sprites["player"].src_rect = Rect.new(0,0,charwidth/4,charheight/4)
    end
    for i in 0...trainer.party.length
      @sprites["party#{i}"]=PokemonIconSprite.new(trainer.party[i],@viewport)
      @sprites["party#{i}"].z=99999
      @sprites["party#{i}"].x=151*2+33*2*(i&1)
      @sprites["party#{i}"].y=36*2+25*2*(i/2)
    end
  end

  def pbChoose(commands)
    @sprites["cmdwindow"].commands=commands
    loop do
      Graphics.update
      Input.update
      pbUpdate
      if Input.trigger?(Input::C)
        return @sprites["cmdwindow"].index
      end
    end
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites) { pbUpdate }
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end

  def pbCloseScene
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
end

class PokemonLoad
  def initialize(scene)
    @scene=scene
  end

  def pbTryLoadFile(savefile)
    trainer=nil
    framecount=nil
    game_system=nil
    pokemonSystem=nil
    mapid=nil
    File.open(savefile){|f|
       trainer=Marshal.load(f)
       framecount=Marshal.load(f)
       game_system=Marshal.load(f)
       pokemonSystem=Marshal.load(f)
       mapid=Marshal.load(f)
    }
    raise "Archivo corrupto" if !trainer.is_a?(PokeBattle_Trainer)
    raise "Archivo corrupto" if !framecount.is_a?(Numeric)
    raise "Archivo corrupto" if !game_system.is_a?(Game_System)
    raise "Archivo corrupto" if !pokemonSystem.is_a?(PokemonSystem)
    raise "Archivo corrupto" if !mapid.is_a?(Numeric)
    return [trainer,framecount,game_system,pokemonSystem,mapid]
  end

  def pbStartLoadScreen
    $PokemonTemp   = PokemonTemp.new
    $game_temp     = Game_Temp.new
    $game_system   = Game_System.new
    $PokemonSystem = PokemonSystem.new if !$PokemonSystem
    cmdContinue    = -1
    cmdNewGame     = -1
    cmdOption      = -1
    cmdLanguage    = -1
    cmdMysteryGift = -1
    cmdSelectSlot  = -1
    cmdQuit        = -1
    commands       = []
    savefile = RTP.getSaveFileName("Game.rxdata")
    data_system = pbLoadRxData("Data/System")
    mapfile=sprintf("Data/Map%03d.rxdata",data_system.start_map_id)
    if data_system.start_map_id==0 || !pbRgssExists?(mapfile)
      Kernel.pbMessage(_INTL("No se estableció una posición inicial en el mapa.\1"))
      Kernel.pbMessage(_INTL("El juego no puede continuar."))
      @scene.pbEndScene
      $scene=nil
      return
    end
    
    trainer=nil
    framecount=0
    mapid=0
    showContinue=false
    haveBackup=false
    
    active_slot = SaveSlotsManager.getActiveSlot
    savefile = SaveSlotsManager.getSaveFileName(active_slot)
    
    if safeExists?(savefile)
      begin
        trainer, framecount, $game_system, $PokemonSystem, mapid=pbTryLoadFile(savefile)
        showContinue=true
      rescue
        if safeExists?(savefile+".bak")
          begin
            trainer, framecount, $game_system, $PokemonSystem, mapid=pbTryLoadFile(savefile+".bak")
            haveBackup=true
            showContinue=true
          rescue
          end
        end
        if haveBackup
          Kernel.pbMessage(_INTL("El archivo guardado está corrupto. Se cargará el archivo guardado previo."))
        else
          Kernel.pbMessage(_INTL("El archivo guardado está corrupto o es incompatible con este juego."))
          if !Kernel.pbConfirmMessageSerious(_INTL("¿Quieres borrar el archivo guardado para iniciar uno nuevo?"))
            raise "scss error - Corrupted or incompatible save file."
          end
          begin; File.delete(savefile); rescue; end
          begin; File.delete(savefile+".bak"); rescue; end
          $game_system=Game_System.new
          $PokemonSystem=PokemonSystem.new if !$PokemonSystem
          Kernel.pbMessage(_INTL("El archivo guardado fue borrado."))
        end
      end
      if showContinue
        if !haveBackup
          begin; File.delete(savefile+".bak"); rescue; end
        end
      end
    end
    
    commands[cmdContinue=commands.length]=_INTL("Continuar") if showContinue
    commands[cmdSelectSlot=commands.length]=_INTL("Seleccionar Partida")
    commands[cmdNewGame=commands.length]=_INTL("Partida Nueva")
    commands[cmdMysteryGift=commands.length]=_INTL("Regalo Misterioso") if (trainer.mysterygiftaccess rescue false) || MYSTERYGIFTALWAYSSHOW
    commands[cmdOption=commands.length]=_INTL("Opciones")
    commands[cmdLanguage=commands.length]=_INTL("Idioma") if LANGUAGES.length>=2
    commands[cmdQuit=commands.length]=_INTL("Salir del Juego")
    @scene.pbStartScene(commands,showContinue,trainer,framecount,mapid)
    @scene.pbSetParty(trainer) if showContinue
    @scene.pbStartScene2
    $ItemData = readItemList("Data/items.dat")
    loop do
      command=@scene.pbChoose(commands)
      if cmdContinue>=0 && command==cmdContinue
        unless safeExists?(SaveSlotsManager.getSaveFileName)
          pbPlayBuzzerSE()
          next
        end
        pbLoadGame
        return
      elsif cmdSelectSlot>=0 && command==cmdSelectSlot
        pbShowSlotSelectionScreen
        @scene.pbEndScene
        $scene=pbCallTitle
        return
      elsif cmdNewGame>=0 && command==cmdNewGame
        @scene.pbEndScene
        if $game_map && $game_map.events
          for event in $game_map.events.values
            event.clear_starting
          end
        end
        $game_temp.common_event_id=0 if $game_temp
        $scene               = Scene_Map.new
        Graphics.frame_count = 0
        $game_system         = Game_System.new
        $game_switches       = Game_Switches.new
        $game_variables      = Game_Variables.new
        $game_self_switches  = Game_SelfSwitches.new
        $game_screen         = Game_Screen.new
        $game_player         = Game_Player.new
        $PokemonMap          = PokemonMapMetadata.new
        $PokemonGlobal       = PokemonGlobalMetadata.new
        $PokemonStorage      = PokemonStorage.new
        $PokemonEncounters   = PokemonEncounters.new
        $PokemonTemp.begunNewGame=true
        $data_system         = pbLoadRxData("Data/System")
        $MapFactory          = PokemonMapFactory.new($data_system.start_map_id)
        $game_player.moveto($data_system.start_x, $data_system.start_y)
        $game_player.refresh
        $game_map.autoplay
        $game_map.update
        return
      elsif cmdMysteryGift>=0 && command==cmdMysteryGift
        pbFadeOutIn(99999){
           trainer=pbDownloadMysteryGift(trainer)
        }
      elsif cmdOption>=0 && command==cmdOption
        scene=PokemonOptionScene.new
        screen=PokemonOption.new(scene)
        pbFadeOutIn(99999) { screen.pbStartScreen(true) }
      elsif cmdLanguage>=0 && command==cmdLanguage
        @scene.pbEndScene
        $PokemonSystem.language=pbChooseLanguage
        pbLoadMessages("Data/"+LANGUAGES[$PokemonSystem.language][1])
        savedata=[]
        active_slot = SaveSlotsManager.getActiveSlot
        savefile = SaveSlotsManager.getSaveFileName(active_slot)
        if safeExists?(savefile)
          File.open(savefile,"rb"){|f|
             15.times { savedata.push(Marshal.load(f)) }
          }
          savedata[3]=$PokemonSystem
          begin
            File.open(SaveSlotsManager.getSaveFileName(active_slot),"wb"){|f|
               15.times {|i| Marshal.dump(savedata[i],f) }
            }
          rescue
          end
        end
        $scene=pbCallTitle
        return
      elsif cmdQuit>=0 && command==cmdQuit
        @scene.pbEndScene
        $scene=nil
        return
      end
    end
    @scene.pbEndScene
    return
  end

  def pbShowSlotSelectionScreen
    loop do
      Graphics.update
      Input.update
      
      commands = []
      for i in 1..SaveSlotsManager::TOTAL_SLOTS
        commands.push(pbGetSlotDisplayName(i))
      end
      
      choice = Kernel.pbShowCommands(nil, commands, -1)
      if choice < 0
        break
      end
      
      selected_slot = choice + 1
      slot_info = SaveSlotsManager.getSlotInfo(selected_slot)
      
      if slot_info
        if Kernel.pbConfirmMessage(_INTL("¿Cargar la partida del slot {1}?", selected_slot))
          SaveSlotsManager.setActiveSlot(selected_slot)
          pbLoadGame
          return
        end
      else
        Kernel.pbMessage(_INTL("Este slot está vacío."))
      end
    end
  end

  def pbGetSlotDisplayName(slot_number)
    slot_info = SaveSlotsManager.getSlotInfo(slot_number)
    if slot_info
      trainer = slot_info[0]
      framecount = slot_info[1]
      if trainer
        totalsec = (framecount || 0) / Graphics.frame_rate
        hour = totalsec / 60 / 60
        min = totalsec / 60 % 60
        return _INTL("Slot {1} - {2} ({3}h {4}m)", slot_number, trainer.name, hour, min)
      end
    end
    return _INTL("Slot {1} - <vacío>", slot_number)
  end

  def pbLoadGame
    active_slot = SaveSlotsManager.getActiveSlot
    savefile = SaveSlotsManager.getSaveFileName(active_slot)
    @scene.pbEndScene
    metadata=nil
    File.open(savefile){|f|
       $Trainer             = Marshal.load(f)
       framecount           = Marshal.load(f)
       $game_system         = Marshal.load(f)
       Marshal.load(f)
       Marshal.load(f)
       $game_switches       = Marshal.load(f)
       $game_variables      = Marshal.load(f)
       $game_self_switches  = Marshal.load(f)
       $game_screen         = Marshal.load(f)
       $MapFactory          = Marshal.load(f)
       $game_map            = $MapFactory.map
       $game_player         = Marshal.load(f)
       $PokemonGlobal       = Marshal.load(f)
       $PokemonGlobal.coins = $PokemonGlobal.coins.to_i  # ← AÑADE ESTO
       metadata             = Marshal.load(f)
       $PokemonBag          = Marshal.load(f)
       $PokemonStorage      = Marshal.load(f)
       Graphics.frame_count = framecount
       magicNumberMatches=false
       if $data_system.respond_to?("magic_number")
         magicNumberMatches=($game_system.magic_number==$data_system.magic_number)
       else
         magicNumberMatches=($game_system.magic_number==$data_system.version_id)
       end
       if !magicNumberMatches || $PokemonGlobal.safesave
         if pbMapInterpreterRunning?
           pbMapInterpreter.setup(nil,0)
         end
         begin
           $MapFactory.setup($game_map.map_id)
         rescue Errno::ENOENT
           if $DEBUG
             Kernel.pbMessage(_INTL("No se encontró el mapa {1}.",$game_map.map_id))
             map=pbWarpToMap()
             if map
               $MapFactory.setup(map[0])
               $game_player.moveto(map[1],map[2])
             else
               $game_map=nil
               $scene=nil
               return
             end
           else
             $game_map=nil
             $scene=nil
             Kernel.pbMessage(_INTL("No se encontró el mapa. El juego no puede continuar."))
           end
         end
         $game_player.center($game_player.x, $game_player.y)
       else
         $MapFactory.setMapChanged($game_map.map_id)
       end
    }
    if !$game_map.events
      $game_map=nil
      $scene=nil
      Kernel.pbMessage(_INTL("El mapa está corrupto. El juego no puede continuar."))
      return
    end
$PokemonMap=metadata
$PokemonEncounters=PokemonEncounters.new
$PokemonEncounters.setup($game_map.map_id)
$game_map.update
$PokemonMap.updateMap
$playMapMusic = true
$scene = Scene_Map.new
return
  end
end
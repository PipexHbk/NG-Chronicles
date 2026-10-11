############################################
#    Encounter List Window by raZ   #
#     Additions from Nuri Yuri, Vendily    #
#                  v1.2                    #
#   Icon edits + NatDex iter. by Zaffre
#       Adaptacion a v16 por MrGrossi      #
############################################
#    To use it, call EncounterListUI       #
#    like any other screen:                #
#                                          #
#    screen = EncounterListUI.new          #
#                                          #
#   PLEASE NOTE: Icon version only works   #
#       with 3 rows of encounters!         #
############################################
 
# just note that the species text is using whatever colour ID 0 is, black by default
# if your message box background is dark, you can either edit the default colour
# to be white, or add in a <c2> where it says <al>%s</al> with the white colour
 
 
WINDOWSKIN = "base.png"
 
# This hash allows you to define the names of your encounter types if you want them to be more logical
# E.g. "Surfing" instead of "Water"
# If missing, the script will use the encounter type names in GameData::EncounterTypes
USER_DEFINED_NAMES = [
"Hierba",
"Cueva",
"Surf",
"Golpe Roca",
"Caña Vieja",
"Caña Buena",
"Súper Caña",
"Golpe Cabeza",
"Golpe Cabeza",
"Hierba (Mañana)",
"Hierba (Mediodía)",
"Hierba (Noche)",
"Concurso de captura de bichos"
]
 
class EncounterListUI
 
  # Constructor method
  # Sets a handful of key variables needed throughout the script
  def initialize
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @viewport2 = Viewport.new(30, 180, Graphics.width, Graphics.height)
    @viewport2.z = 999999
    @sprites = {}
    mapid = $game_map.map_id
    @index = 0
    @encounter_name_indexes = []
    @encounter_data = load_data("Data/encounters.dat")
    if @encounter_data.is_a?(Hash) && @encounter_data[mapid]
      @encounter_tables = Marshal.load(Marshal.dump(@encounter_data[mapid][1]))
 
      for i in 0..@encounter_tables.length-1
        if(@encounter_tables[i] != nil)
          @encounter_name_indexes.push(i)
        end
      end
      @encounter_tables =@encounter_tables.compact
      @enc_array = pbListOfEncounters(@encounter_tables)
      @max_enc = @encounter_tables[@index].length
      @eLength = @encounter_tables.length
    else
      @max_enc, @eLength = [1, 1]
      @enc_array = [7]
    end
 
  end
 
  def getMaxEncounters(data)
    keys = data.keys
    a = []
    for key in keys
      b = []
      arr = data[key]
      for i in 0...arr.length
        b.push( arr[i][1] )
      end
      a.push(b.uniq.length)
    end
    return a.max, keys.length
  end
 
  def pbStartScene
    if !File.file?("Graphics/Pictures/EncounterUI/"+WINDOWSKIN)
      raise _INTL("You are missing the graphic for this UI. Make sure the image is in your Graphics/Pictures folder and that it is named appropriately.")
    end
    addBackgroundPlane(@sprites,"bg","EncounterUI/bg",@viewport)
    @sprites["base"] = IconSprite.new(0,0,@viewport)
    @sprites["base"].setBitmap("Graphics/Pictures/EncounterUI/"+WINDOWSKIN)
    @sprites["base"].ox = @sprites["base"].bitmap.width/2
    @sprites["base"].oy = @sprites["base"].bitmap.height/2
    @sprites["base"].x = Graphics.width/2; @sprites["base"].y = Graphics.height/2
    @sprites["base"].opacity = 255
    @sprites["locwindow"] = Window_AdvancedTextPokemon.new("")
    @sprites["locwindow"].viewport = @viewport
    @sprites["locwindow"].width = 512
    @sprites["locwindow"].height = 344
    @sprites["locwindow"].x = (Graphics.width - @sprites["locwindow"].width)/2
    @sprites["locwindow"].y = (Graphics.height - @sprites["locwindow"].height)/2
    @sprites["locwindow"].windowskin = nil
    @h = (Graphics.height - @sprites["base"].bitmap.height)/2
    @w = (Graphics.width - @sprites["base"].bitmap.width)/2
 
 
    #@max_enc.times do |i|
    #  @sprites["icon_#{i}"] = PokemonSpeciesIconSprite.new(nil,@viewport)
    #  @sprites["icon_#{i}"].x = @w + 28 + 64*(i%7)
    #  @sprites["icon_#{i}"].y = @h + 100 + (i/7)*64
    #  @sprites["icon_#{i}"].visible = false
    #end
 
    @sprites["rightarrow"] = AnimatedSprite.new("Graphics/Pictures/rightarrow",8,40,28,2,@viewport)
    @sprites["rightarrow"].x = Graphics.width - @sprites["rightarrow"].bitmap.width
    @sprites["rightarrow"].y = Graphics.height/2 - @sprites["rightarrow"].bitmap.height/16
    @sprites["rightarrow"].visible = false
    @sprites["rightarrow"].play
    @sprites["leftarrow"] = AnimatedSprite.new("Graphics/Pictures/leftarrow",8,40,28,2,@viewport)
    @sprites["leftarrow"].x = 0
    @sprites["leftarrow"].y = Graphics.height/2 - @sprites["rightarrow"].bitmap.height/16
    @sprites["leftarrow"].visible = false
    @sprites["leftarrow"].play
 
    temparray = @enc_array.dup
    (temparray.pop!=7) ? drawPresent : drawAbsent
 
 
    main
  end
 
  def drawPresent
    @sprites["rightarrow"].visible = (@index < @eLength-1) ? true : false
    @sprites["leftarrow"].visible = (@index > 0) ? true : false
 
    @enc_array, currKey = getEncData
    encstringarray = []
    i = 0
    @enc_array.each do |specie|
       encstringarray.push(PBSpecies.getName(specie))#+", ")
       @sprites["icon_#{i}"]=PokemonSpeciesIconSprite.new(specie,@viewport2)
       if !$Trainer.seen[specie]
          @sprites["icon_#{i}"].pbSetParams(specie,0,0)
          @sprites["icon_#{i}"].tone = Tone.new(-255,-255,-255,0)
          @sprites["icon_#{i}"].visible = true
       elsif !$Trainer.owned[specie]
          @sprites["icon_#{i}"].pbSetParams(specie,0,0)
          @sprites["icon_#{i}"].tone = Tone.new(0,0,0,255)
          @sprites["icon_#{i}"].visible = true
       else
          @sprites["icon_#{i}"].pbSetParams(specie,0,0)
          @sprites["icon_#{i}"].tone = Tone.new(0,0,0,0)
          @sprites["icon_#{i}"].visible = true
       end
       if i > 6 && i < 14
         @sprites["icon_#{i}"].y += 64
         @sprites["icon_#{i}"].x = (64 * (i-7))
       elsif i > 13
         @sprites["icon_#{i}"].y += 128
         @sprites["icon_#{i}"].x = (64 * (i-14))
       else
         @sprites["icon_#{i}"].x += 64 * i
       end
       i +=1
     end
 
 
 
    loctext = _INTL("<ac><c2=7FF05EE8>{1}</c2></ac>", $game_map.name)
    loctext += sprintf(_INTL("<al><c2=7FF05EE8>Pokémon salvajes en este entorno: %s</c2></al>"),@enc_array.length)
    loctext += sprintf("<c2=7FF05EE8>-----------------------------------------</c2>")
    loctext += sprintf(_INTL("<ac><c2=44D87762>%s</c2></ac>"),USER_DEFINED_NAMES[@encounter_name_indexes[@index]])
    @sprites["locwindow"].setText(loctext)
  end
 
  def drawAbsent
    loctext = _INTL("<ac><c2=7FF05EE8>{1}</c2></ac>", $game_map.name)
    loctext += sprintf(_INTL("<al><c2=7FF05EE8>Este área no tiene Pokémon salvajes</c2></al>"))
    loctext += sprintf(_INTL("<c2=7FF05EE8>-----------------------------------------</c2>"))
    @sprites["locwindow"].setText(loctext)
  end
 
  def pbUpdate
    pbUpdateSpriteHash(@sprites)
  end
 
 
  def pbListOfEncounters(encounter)   # this method is from Nuri Yuri
    return [] unless encounter
 
    encable = encounter.compact # remove nils
    encable.map! { |enc_list| enc_list.map { |enc| enc[0] } }
    encable.flatten! # transform array of array into array
    encable.uniq! # prevent duplication
 
    return encable
  end
 
  def getEncData
    mapid = $game_map.map_id
    currKey = @encounter_tables[@index]
    enc_array = []
    arr = []
 
    #@encounter_tables[currKey].each { |s| arr.push( s[1] ) }
 
    arr = pbListOfEncounters(@encounter_tables)
    @temp = 0
 
    for i in 0..arr.length-1
      id = getID(PBSpecies,pbGetSpeciesConst(arr[i]))
      for j in 0..@encounter_tables[@index].length-1
        if(@encounter_tables[@index][j].include?(id) && !enc_array.include?(id))
          enc_array.push(id)
        end
      end
    end
 
    @max_enc = @encounter_tables[@index].length
 
    return enc_array, currKey
  end
 
  def main
    loop do
      Graphics.update
      Input.update
      if Input.trigger?(Input::RIGHT) && @eLength >1 && @index< @eLength-1
        pbPlayCursorSE
        hideSprites
        @index += 1
        drawPresent
      elsif Input.trigger?(Input::LEFT) && @eLength >1 && @index !=0
        pbPlayCursorSE
        hideSprites
        @index -= 1
        drawPresent
      elsif Input.trigger?(Input::B)
        pbPlayCancelSE
        Input.update
        break
      end
    end
    dispose
  end
 
  def dispose
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
    @viewport2.dispose
  end
 
   # Hide sprites
  def hideSprites
    for i in 0...@enc_array.length
      @sprites["icon_#{i}"].visible = false
    end
  end
end
 
class EncounterList_Screen
  def initialize()
    @scene = EncounterListUI.new
    pbStartScreen
  end
 
  def pbStartScreen
    @scene.pbStartScene
    #@scene.pbEncounter
    #@scene.pbEndScene
  end
end

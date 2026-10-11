######Incubadora de: KYU  ######################################################
#Hay dos formas de usar este script:
#   -Creando un objeto:
#     Primero, añade la siguiente linea en el PBS de objetos.
#     (cambia xxx por la id del objeto)
#        XXX,INCUBADORA,Incubadora,Incubadoras,8,0,"Una incubadora en la que portar hasta 6 huevos hasta que eclosionen",2,0,6
#     Si estás usando la v19, añade INCUBADORA.png a la carpeta Graphics/Items.
#     En caso contrario, añade itemXXX.png a la carpeta Graphics/Icons.
#     
#     La funcionalidad del objeto ya está implementada en este script. 
#     Eso incluye usar el objeto y almacenar huevos cuando se reciban.
#
#   -Llamada por script:
#     Ya sea desde el menú o un NPC cualquiera, usa este metodo para abrirla:
#         openHatcher
#     En caso de usar este método, puedes usar un interruptor global para
#     indicar que está disponible. 
#     Tan solo cambia EGGHATCHER_SWITCH a la id del interruptor que quieres usar.
# 
#ES OBLIGATORIO DAR TODOS LOS CRÉDITOS CORRESPONDIENTES SI SE USA ESTE SCRIPT.
################################################################################
# CONSTANTES
################################################################################
EGGHATCHER_SWITCH = 50 # Interruptor global para indicar disponibilidad
################################################################################

if defined?(PluginManager)
  PluginManager.register({
  :name => "Egg Hatcher",
  :version => "1.1",
  :credits => ["Kyu","Clara","Turner"]
  })
end

class PokemonGlobalMetadata
  attr_accessor :eggs
  alias old_initialize initialize
  def initialize
    old_initialize
    @eggs ||= [nil,nil,nil,nil,nil,nil]
  end
end

#Caja individual de cada incubadora
class EggSprite < SpriteWrapper
  def initialize(viewport,selected,pokemon, x, y)
    super(viewport)
    @sprites = {}
    @animframe = 0
    @curFrame = 0
    @pokemon = pokemon
    @selected = selected
    self.bitmap = Bitmap.new(68, 100)
    self.x = x
    self.y = y
    refresh
  end
  
  def refresh
    if @pokemon != nil
      @frameskip = 20
      if defined?(Essentials) && defined?(Settings::EGG_LEVEL)
        #V19
        steps = @pokemon.steps_to_hatch
        sprite = GameData::Species.egg_icon_filename(@pokemon.species, @pokemon.form)
      else
        #V16-17-18
        steps = @pokemon.eggsteps
        sprite = "Graphics/Icons/iconEgg"
      end
      @frameskip = 15 if steps<10200
      @frameskip = 10 if steps<2550
      @frameskip = 5 if steps<1275
      @sprites["egg"] = AnimatedSprite.create(sprite,2,@frameskip,self.viewport)
      @sprites["egg"].x = self.x + 2
      @sprites["egg"].y = self.y - 5
      @sprites["egg"].play
      base = Color.new(6,35,52)
      shadow= Color.new(169,179,184)
      pbSetSystemFont(self.bitmap)
      pbDrawTextPositions(self.bitmap,[[steps.to_s,35,
      defined?(Essentials) && defined?(Settings::EGG_LEVEL) ? 60 : 65,2,base,shadow]])
    end

    if @selected
      self.bitmap.blt(0,0,Bitmap.new("Graphics/Pictures/Incubadora/selection"),Rect.new(0,0,68,100))
    end
  end

  def dispose
    super
    pbDisposeSpriteHash(@sprites)
  end
  
  def update
    pbUpdateSpriteHash(@sprites)
  end
end

#Escena global
class Hatcher
  def initialize
    if !$PokemonGlobal.eggs
      $PokemonGlobal.eggs ||= [nil,nil,nil,nil,nil,nil]
    end
    @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z = 99999
    @sprites = {}
    @eggs = {}
    @index = 0
    
    @sprites["bg"] = Sprite.new(@viewport)
    @sprites["bg"].bitmap = Bitmap.new("Graphics/Pictures/Incubadora/hatcherbg")

    @sprites["text"] = Sprite.new(@viewport)
    @sprites["text"].bitmap = Bitmap.new(183,183)
    @sprites["text"].x = 290 
    @sprites["text"].y = 80
    pbSetSystemFont(@sprites["text"].bitmap)
    refresh
  end
  
  def refresh
    disposeEggs
    @sprites["text"].bitmap.clear
    eggs = $PokemonGlobal.eggs
    for index in 0..5
      if index < 3
        x = 46 + 80*index
        y = 46
      else
        x = 46 + 80*(index - 3)
        y = 158
      end
      selected = (index == @index)? true : false
      @eggs["#{index}"] = EggSprite.new(@viewport,selected,eggs[index], x, y)
    end
    
    if eggs[@index] != nil
      pokemon = eggs[@index]
      if defined?(Essentials) && defined?(Settings::EGG_LEVEL)
        #V19
        steps = pokemon.steps_to_hatch
      else
        #V16-17-18
        steps = pokemon.eggsteps
      end
      eggstate=_INTL("Parece que a este Huevo le tomará mucho tiempo abrirse.")
      eggstate=_INTL("¿Qué saldrá? Aún le queda para abrirse.") if steps<10200
      eggstate=_INTL("A veces se mueve. Debería abrirse pronto.") if steps<2550
      eggstate=_INTL("Está haciendo ruidos. ¡Está a punto de abrirse!") if steps<1275
      drawFormattedTextEx(@sprites["text"].bitmap,0,0,183,eggstate)
    end
  end
  
  def disposeEggs
    @eggs.each_value{|egg|
      egg.dispose
    }
  end
  
  def dispose
    disposeEggs
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
  
  def update
    loop do
      @eggs.each_value{|egg|
      egg.update
      }
      #Selector
      if Input.trigger?(Input::RIGHT) && (@index+1)%3 != 0
        @index += 1
        pbSEPlay("Choose")
        refresh
      end
      if Input.trigger?(Input::LEFT) && (@index != 0 && @index != 3)
        @index -= 1
        pbSEPlay("Choose")
        refresh
      end
      if Input.trigger?(Input::UP) && @index >= 3
        @index -= 3
        pbSEPlay("Choose")
        refresh
      end
      if Input.trigger?(Input::DOWN) && @index <= 2 
        @index += 3
        pbSEPlay("Choose")
        refresh
      end
      #Manipular una incubadora
      if Input.trigger?(Input::C) || Input.trigger?(Input::A)
        if $PokemonGlobal.eggs[@index] == nil
          ret = Kernel.pbConfirmMessage("No hay ningún huevo en esta incubadora\\n¿Quieres añadir uno?")
          if ret == true
            chosen=0
            pbFadeOutIn(99999){
              #Compatibilidad con Essentials v18.1
              if defined?(PokemonScreen_Scene) == 'constant' && PokemonScreen_Scene.class == Class
                scene=PokemonScreen_Scene.new
                screen=PokemonScreen.new(scene,$Trainer.party)
                screen.pbStartScene(_INTL("Elige un Pokémon."),false)
                chosen=screen.pbChoosePokemon
                screen.pbEndScene
              else #Essentials v16.2 y v17
                scene = PokemonParty_Scene.new
                screen = PokemonPartyScreen.new(scene,$Trainer.party)
                screen.pbStartScene(_INTL("Elige un Pokémon."),false)
                chosen=screen.pbChoosePokemon
                screen.pbEndScene
              end
            }
            if $Trainer.party[chosen] != nil
              if !$Trainer.party[chosen].egg?
                Kernel.pbMessage("El pokémon elegido no es un huevo")
              else
                $PokemonGlobal.eggs[@index] = $Trainer.party[chosen]
                $Trainer.party.delete_at(chosen)
              end
            end
          end
        else
          ret = Kernel.pbConfirmMessage("¿Quieres retirar este huevo?")
          if ret == true
            takeEgg($PokemonGlobal.eggs[@index],@index)
          end
        end
        refresh
      end
      #Finalizar escena
      if Input.trigger?(Input::B)
        dispose
        Input.update
        break
      end
    
      Graphics.update
      Input.update
    end
  end
end

def takeEgg(egg,index)
  sel = Kernel.pbConfirmMessage(_INTL("¿Quieres añadir al pokémon al equipo?"))
  if sel==true
    Kernel.pbMessage(_INTL("Your party is full\1")) if $Trainer.party.length == 6
    pbStorePokemon(egg)
  else
    if pbBoxesFull?
      Kernel.pbMessage(_INTL("¡No hay espacio para el Pokémon!\1"))
      Kernel.pbMessage(_INTL("¡Las Cajas de la PC están llenas y no aceptan ni un Pokémon más!"))
      return
    end
    oldcurbox=$PokemonStorage.currentBox
    storedbox=$PokemonStorage.pbStoreCaught(egg)
    curboxname=$PokemonStorage[oldcurbox].name
    boxname=$PokemonStorage[storedbox].name
    creator=nil
    creator=Kernel.pbGetStorageCreator if $PokemonGlobal.seenStorageCreator
    if storedbox!=oldcurbox
      if creator
        Kernel.pbMessage(_INTL("La caja \"{1}\" está llena.\1",curboxname,creator))
      else
        Kernel.pbMessage(_INTL("La caja \"{1}\" está llena.\1",curboxname))
      end
      Kernel.pbMessage(_INTL("{1} fue transferido a la caja \"{2}.\"",egg.name,boxname))
    else
      Kernel.pbMessage(_INTL("{1} fue transferido a la caja \"{2}.\"",egg.name,boxname))
    end
  end
  $PokemonGlobal.eggs[index] = nil
end

if defined?(Essentials) && defined?(Settings::EGG_LEVEL)
  #V19
  def pbGenerateEgg(pkmn, text = "")
    return false if !pkmn || $Trainer.party_full?
    pkmn = Pokemon.new(pkmn, Settings::EGG_LEVEL) if !pkmn.is_a?(Pokemon)
    # Detalles del huevo
    pkmn.name           = _INTL("Egg")
    pkmn.steps_to_hatch = pkmn.species_data.hatch_steps
    pkmn.obtain_text    = text
    pkmn.calc_stats
    # Añadir huevo al equipo
    if (GameData::Item.exists?(:INCUBADORA) && $PokemonBag.pbHasItem?(:INCUBADORA)) || $game_switches[EGGHATCHER_SWITCH]
      ret = Kernel.pbConfirmMessage("¿Quieres meter el huevo en la incubadora?")
      if ret == true
        ret = addEgg(pkmn)
        if ret == true
          return true
        end
      end
    end
    pbStorePokemon(pkmn)
    return true
  end
else
  #V16-17-18
  def pbGenerateEgg(pokemon,text="",steps=nil)
    return false if !pokemon || !$Trainer
    if pokemon.is_a?(String) || pokemon.is_a?(Symbol)
      pokemon=getID(PBSpecies,pokemon)
    end
    begin
      if pokemon.is_a?(Integer)
      pokemon=PokeBattle_Pokemon.new(pokemon,EGGINITIALLEVEL,$Trainer)
      end
      # Pasos para eclosionar
      dexdata=pbOpenDexData
      pbDexDataOffset(dexdata,pokemon.species,21)
      eggsteps=dexdata.fgetw
      dexdata.close
      # Detalles del huevo
      pokemon.name=_INTL("Huevo")
      if steps !=nil
        pokemon.eggsteps=steps
      else
        pokemon.eggsteps=eggsteps
      end
      pokemon.obtainText=text
      pokemon.calcStats
    rescue
      pokemon = getID(PBSpecies,pokemon)
      if pokemon.is_a?(Integer)
        pokemon = pbNewPkmn(pokemon,EGG_LEVEL)
      end
      # Pasos para eclosionar
      eggSteps = pbGetSpeciesData(pokemon.species,pokemon.form,SpeciesStepsToHatch)
      # Detalles del huevo
      pokemon.name       = _INTL("Huevo")
      if steps !=nil
        pokemon.eggsteps=steps
      else
        pokemon.eggsteps=eggsteps
      end
      pokemon.obtainText = text
      pokemon.calcStats
    end
    # Añadir huevo a la incubadora
    if (getID(PBItems,:INCUBADORA)==-1 && $PokemonBag.pbHasItem?(:INCUBADORA)) || $game_switches[EGGHATCHER_SWITCH]
      ret = Kernel.pbConfirmMessage("¿Quieres meter el huevo en la incubadora?")
      if ret == true
        ret = addEgg(pokemon)
        if ret == true
          return true
        end
      end
    end
    pbStorePokemon(pokemon)
    return true
  end
end

def addEgg(egg)
  if !$PokemonGlobal.eggs
    $PokemonGlobal.eggs ||= [nil,nil,nil,nil,nil,nil]
  end
  $PokemonGlobal.eggs.each_index{|index|
    if $PokemonGlobal.eggs[index] == nil
      $PokemonGlobal.eggs[index] = egg
      return true
    end
  }
  Kernel.pbMessage("No hay espacio en la incubadora")
  return false
end

if defined?(Essentials) && defined?(Settings::EGG_LEVEL)
  #V19
  Events.onStepTaken+=proc {|sender,e|
     next if !$Trainer || !$PokemonGlobal.eggs
     for i in 0...$PokemonGlobal.eggs.length
       egg = $PokemonGlobal.eggs[i]
       next if egg == nil
       if egg.steps_to_hatch>0
         egg.steps_to_hatch-=1
         for x in $Trainer.party
           if x.hasAbility?(:FLAMEBODY) ||
              x.hasAbility?(:MAGMAARMOR)
             egg.steps_to_hatch-=1
             break
           end
         end
         if egg.steps_to_hatch<=0
          egg.steps_to_hatch=0
          pbHatch(egg)
          takeEgg(egg,i)
         end
       end
     end
  }
else
  #V16-17-18
  Events.onStepTaken+=proc {|sender,e|
     next if !$Trainer || !$PokemonGlobal.eggs
     for i in 0...$PokemonGlobal.eggs.length
       egg = $PokemonGlobal.eggs[i]
       next if egg == nil
       if egg.eggsteps>0
         egg.eggsteps-=1
         for x in $Trainer.pokemonParty
           if isConst?(x.ability,PBAbilities,:FLAMEBODY) ||
              isConst?(x.ability,PBAbilities,:MAGMAARMOR)
             egg.eggsteps-=1
             break
           end
         end
         if egg.eggsteps<=0
          egg.eggsteps=0
          pbHatch(egg)
          takeEgg(egg,i)
         end
       end
     end
  }
end

ItemHandlers::UseFromBag.add(:INCUBADORA,proc{|item|
  pbFadeOutIn(99999){
    openHatcher
  }
  next 1
})

def openHatcher
  scene = Hatcher.new
  scene.update
end


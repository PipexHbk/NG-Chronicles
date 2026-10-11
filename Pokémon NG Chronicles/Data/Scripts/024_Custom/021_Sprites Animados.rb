#Script Original creado por: Luka S.J
#Versión ULTRA LIGERA para Joiplay
POKEMONSPRITESCALE = 2  # Reducido para Joiplay
BACKSPRITESCALE = 3     # Reducido para Joiplay

class DynamicPokemonSprite
  attr_accessor :shadow
  attr_accessor :sprite
  attr_accessor :showshadow
  attr_accessor :status
  attr_accessor :hidden
  attr_accessor :fainted
  attr_accessor :anim
  attr_accessor :charged
  attr_accessor :isShadow
  attr_reader :loaded
  attr_reader :selected
  attr_reader :isSub
  attr_reader :viewport
  attr_reader :pulse

  def initialize(doublebattle,index,viewport=nil)
    @viewport=viewport
    @metrics=load_data("Data/metrics.dat")
    @selected=0
    @frame=0
    @frame2=0
    @frame3=0
    
    @status=0
    @loaded=false
    @charged=false
    @index=index
    @doublebattle=doublebattle
    @showshadow=true
    @altitude=8
    @yposition=8
    @shadow=Sprite.new(@viewport)
    @sprite=Sprite.new(@viewport)
    @sprite2=Sprite.new(@viewport)
    back=(@index%2==0)
    @substitute=AnimatedBitmapWrapper.new("Graphics/Battlers/"+(back ? "substitute_back" : "substitute"),POKEMONSPRITESCALE)
    @overlay=Sprite.new(@viewport)
    @isSub=false
    @lock=false
    @pokemon=nil
    @still=false
    @hidden=false
    @fainted=false
    @anim=false
    @isShadow=false
    
    @fp = {}
    @pulse = 8
    @k = 1
  end

  def setPokemonBitmap(pokemon,back=true,species=nil)
    self.resetParticles
    return if !pokemon || pokemon.nil?
    @pokemon = pokemon
    @isShadow = true if @pokemon.isShadow?
    @altitude = @metrics[4][pokemon.species]
    if back
      @yposition = @metrics[10][pokemon.species]
      @altitude *= 10
    else
      @yposition = @metrics[4][pokemon.species]
    end
    scale = back ? BACKSPRITESCALE : POKEMONSPRITESCALE
    if !species.nil?
      @bitmap = pbLoadPokemonBitmapSpecies(pokemon,species,back,scale)
    else
      @bitmap = pbLoadPokemonBitmap(pokemon,back,scale)
    end
    
    @sprite.bitmap = @bitmap.bitmap
    @sprite2.bitmap = @bitmap.bitmap
    @shadow.bitmap = @bitmap.bitmap
    
    @sprite.ox = @bitmap.width/2
    @sprite2.ox = @bitmap.width/1
    @sprite.oy = @bitmap.height
    @sprite2.oy = @bitmap.height
    @sprite.oy += @altitude
    @sprite2.oy += @altitude
    @sprite.oy -= @yposition
    @sprite2.oy -= @yposition
    @sprite.oy -= pokemon.formOffsetY if pokemon.respond_to?(:formOffsetY)
    @sprite2.oy -= pokemon.formOffsetY if pokemon.respond_to?(:formOffsetY)
    
    @fainted = false
    @loaded = true
    @hidden = false
    self.visible = true
    @pulse = 8
    @k = 1
    self.formatShadow
  end
  
  def dispose
    @sprite.bitmap = nil if @sprite
    @sprite2.bitmap = nil if @sprite2
    @shadow.bitmap = nil if @shadow
    @sprite.dispose if @sprite && !@sprite.disposed?
    @sprite2.dispose if @sprite2 && !@sprite2.disposed?
    @shadow.dispose if @shadow && !@shadow.disposed?
    @overlay.dispose if @overlay && !@overlay.disposed?
    @bitmap.dispose if @bitmap && @bitmap.respond_to?(:dispose)
    @substitute.dispose if @substitute && @substitute.respond_to?(:dispose)
  end
end

class AnimatedBitmapWrapper
  attr_reader :width
  attr_reader :height
  attr_reader :totalFrames
  attr_reader :animationFrames
  attr_reader :currentIndex
  attr_accessor :scale
  
  def initialize(file,scale=2)
    raise "filename is nil" if file==nil
    
    @scale = scale
    @width = 0
    @height = 0
    @frame = 0
    @frames = 3  # Más lento = menos actualizaciones
    @direction = +1
    @totalFrames = 0
    @currentIndex = 0
    @speed = 1
    
    bmp = BitmapCache.load_bitmap(file)
    @bitmapFile = bmp
    @width = @bitmapFile.height * @scale
    @height = @bitmapFile.height * @scale
    
    @totalFrames = @bitmapFile.width / @bitmapFile.height
    @animationFrames = @totalFrames * @frames
    @loop_points = [0, @totalFrames]
    
    @actualBitmap = Bitmap.new(@width, @height)
    @actualBitmap.clear
    @actualBitmap.stretch_blt(
      Rect.new(0, 0, @width, @height), 
      @bitmapFile, 
      Rect.new(0, 0, @bitmapFile.height, @bitmapFile.height)
    )
  end
    
  def length; @totalFrames; end
  def disposed?; @actualBitmap.disposed?; end
  def dispose
    @actualBitmap.dispose if @actualBitmap && !@actualBitmap.disposed?
  end
  def bitmap; @actualBitmap; end
  def each; end
    
  def reverse
    @direction = @direction > 0 ? -1 : +1
  end
  
  def setLoop(start, finish)
    @loop_points=[start,finish]
  end
  
  def setSpeed(value)
    @speed=value
  end
  
  def toFrame(frame)
    if frame.is_a?(String)
      frame = frame == "last" ? @totalFrames-1 : 0
    end
    frame = @totalFrames if frame > @totalFrames
    frame = 0 if frame < 0
    @currentIndex = frame
    @actualBitmap.clear
    @actualBitmap.stretch_blt(
      Rect.new(0, 0, @width, @height), 
      @bitmapFile, 
      Rect.new(@currentIndex * @bitmapFile.height, 0, @bitmapFile.height, @bitmapFile.height)
    )
  end
  
  def play
    return if @currentIndex >= @loop_points[1]-1
    self.update
  end
  
  def finished?
    return (@currentIndex==@totalFrames-1)
  end
  
  def update
    return false if @actualBitmap.disposed?
    return false if @speed < 1
    
    @frame += 1
    if @frame >= @frames
      @currentIndex += @direction
      @currentIndex = @loop_points[0] if @currentIndex >= @loop_points[1]
      @currentIndex = @loop_points[1]-1 if @currentIndex < @loop_points[0]
      @frame = 0
      
      @actualBitmap.clear
      @actualBitmap.stretch_blt(
        Rect.new(0, 0, @width, @height), 
        @bitmapFile, 
        Rect.new(@currentIndex * @bitmapFile.height, 0, @bitmapFile.height, @bitmapFile.height)
      )
    end
  end
    
  def deanimate
    @frame = 0
    @currentIndex = 0
    @actualBitmap.clear
    @actualBitmap.stretch_blt(
      Rect.new(0, 0, @width, @height), 
      @bitmapFile, 
      Rect.new(0, 0, @bitmapFile.height, @bitmapFile.height)
    )
  end
end

class BitmapWrapperSprite < Sprite
  def setBitmap(file,scale=BACKSPRITESCALE)
    @animatedBitmap = AnimatedBitmapWrapper.new(file,scale)
    self.bitmap = @animatedBitmap.bitmap
  end
  
  def play
    @animatedBitmap.play
    self.bitmap = @animatedBitmap.bitmap
  end
  
  def finished?; return @animatedBitmap.finished?; end
  def animatedBitmap; return @animatedBitmap; end
  
  def update
    super
    return if @animatedBitmap.nil?
    @animatedBitmap.update
    self.bitmap = @animatedBitmap.bitmap
  end
end

class AnimatedSpriteWrapper < BitmapWrapperSprite; end

# Funciones de carga sin cambios
alias pbLoadPokemonBitmap_ebs pbLoadPokemonBitmap unless defined?(:pbLoadPokemonBitmap_ebs)
def pbLoadPokemonBitmap(pokemon, back = false, scale = POKEMONSPRITESCALE)
  scale = BACKSPRITESCALE if back
  return pbLoadPokemonBitmapSpecies(pokemon, pokemon.species, back, scale)
end

alias pbLoadPokemonBitmapSpecies_ebs pbLoadPokemonBitmapSpecies unless defined?(:pbLoadPokemonBitmapSpecies_ebs)
def pbLoadPokemonBitmapSpecies(pokemon, species, back=false, scale=POKEMONSPRITESCALE)
  ret=nil
  pokemon = pokemon.pokemon if pokemon.respond_to?(:pokemon)
  if pokemon.isEgg?
    bitmapFileName=sprintf("Graphics/Battlers/Eggs/%s",getConstantName(PBSpecies,species)) rescue nil
    if !pbResolveBitmap(bitmapFileName)
      bitmapFileName=sprintf("Graphics/Battlers/Eggs/%03d",species)
      if !pbResolveBitmap(bitmapFileName)
        bitmapFileName=sprintf("Graphics/Battlers/Eggs/000")
      end
    end
    bitmapFileName=pbResolveBitmap(bitmapFileName)
  else
    bitmapFileName=pbCheckPokemonBitmapFiles([species,back,
                                              (pokemon.isFemale?),
                                              pokemon.isShiny?,
                                              (pokemon.form rescue 0),
                                              (pokemon.isShadow? rescue false)])    
  end
  if bitmapFileName.nil?
    p "Missing sprite for #{PBSpecies.getName(species)}"
    bitmapFileName = "Graphics/Battlers/000"
  end
  animatedBitmap=AnimatedBitmapWrapper.new(bitmapFileName,scale) if bitmapFileName
  ret=animatedBitmap if bitmapFileName
  return ret
end

def pbLoadSpeciesBitmap(species,female=false,form=0,shiny=false,shadow=false,back=false,egg=false,scale=POKEMONSPRITESCALE)
  ret = nil
  if egg
    bitmapFileName=sprintf("Graphics/Battlers/Eggs/%s",getConstantName(PBSpecies,species)) rescue nil
    if !pbResolveBitmap(bitmapFileName)
      bitmapFileName=sprintf("Graphics/Battlers/Eggs/%03d",species)
      if !pbResolveBitmap(bitmapFileName)
        bitmapFileName=sprintf("Graphics/Battlers/Eggs/000")
      end
    end
    bitmapFileName=pbResolveBitmap(bitmapFileName)
  else
    bitmapFileName = pbCheckPokemonBitmapFiles([species,back,female,shiny,form,shadow])
  end
  if bitmapFileName
    ret = AnimatedBitmapWrapper.new(bitmapFileName,scale)
  end
  return ret
end

def pbCheckPokemonBitmapFiles(params)
  species = params[0]
  back = params[1]
  factors = []
  factors.push([5,params[5],false]) if params[5] && params[5]!=false
  factors.push([2,params[2],false]) if params[2] && params[2]!=false
  factors.push([3,params[3],false]) if params[3] && params[3]!=false
  factors.push([4,params[4].to_s,""]) if params[4] && params[4].to_s!="" && params[4].to_s!="0"
  tshadow = false
  tgender = false
  tshiny = false
  tform = ""
  for i in 0...2**factors.length
    for j in 0...factors.length
      case factors[j][0]
      when 2
        tgender = ((i/(2**j))%2==0) ? factors[j][1] : factors[j][2]
      when 3
        tshiny = ((i/(2**j))%2==0) ? factors[j][1] : factors[j][2]
      when 4
        tform = ((i/(2**j))%2==0) ? factors[j][1] : factors[j][2]
      when 5
        tshadow = ((i/(2**j))%2==0) ? factors[j][1] : factors[j][2]
      end
    end
    folder = "Graphics/Battlers/"
    if tshiny && back
      folder += "BackShiny/"
    elsif tshiny
      folder += "FrontShiny/"
    elsif back
      folder += "Back/"
    else
      folder += "Front/"
    end
    folder += "Female/" if tgender
    bitmapFileName = sprintf("#{folder}%s%s%s",getConstantName(PBSpecies,species),(tform!="" ? "_"+tform : ""),tshadow ? "_shadow" : "") rescue nil
    ret = pbResolveBitmap(bitmapFileName)
    return ret if ret
    bitmapFileName = sprintf("#{folder}%03d%s%s",species,(tform!="" ? "_"+tform : ""),tshadow ? "_shadow" : "")
    ret = pbResolveBitmap(bitmapFileName)
    return ret if ret
  end
  return nil
end

def pbsetBitmap(species, shiny, back=true, scale=BACKSPRITESCALE)
  folder = "Graphics/Battlers/"
  if shiny && back
    folder += "BackShiny/"
  elsif back
    folder += "Back/"
  end
  name = sprintf("#{folder}%s",getConstantName(PBSpecies,species)) rescue nil
  ret = pbResolveBitmap(name)
  return ret if ret
  name = sprintf("#{folder}%03d",species)
  return pbResolveBitmap(name)
end

def pbPokemonBitmapFile(species, shiny, back=false)
  folder = "Graphics/Battlers/"
  if shiny
    folder += "FrontShiny/"
  else
    folder += "Front/"
  end  
  name = sprintf("#{folder}%s",getConstantName(PBSpecies,species)) rescue nil
  ret = pbResolveBitmap(name)
  return ret if ret
  name = sprintf("#{folder}%03d",species)
  return pbResolveBitmap(name)
end
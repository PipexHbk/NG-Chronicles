INITONENTERING = false
#Si es true, el contador comenzara nada mas entrar al mapa.
class Game_Player
  attr_accessor :iluminationScene #Crea una variable en Game_Player para 
                                #almacenar la clase desde la que se ejecuta todo
end
def startDarkMapCounter(reset=true)
  #Si se quiere que pueda resetear, se debe llamar con true
  if onDarkMap?($game_map.map_id)
    if reset
      $game_player.iluminationScene=IlumScene.new
    else
      $game_player.iluminationScene||=IlumScene.new
    end
  else 
    Kernel.pbMessage("No estás en un mapa marcado como oscuro.")
  end
end
def onDarkMap?(map)
  #Devuelve si el mapa tiene los metadatos requeridos para iniciar
  return pbGetMetadata(map,MetadataDarkMap)
end
#Aquí modifico el proc que se ejecuta al cambiar de mapa:
Events.onMapChanging+=proc{|sender,e|
  if onDarkMap?(e[0]) 
    $game_player.iluminationScene||=IlumScene.new if INITONENTERING
    #Si es un mapa oscuro, lo crea y lo inicializa.
  elsif $game_player.iluminationScene
    #Si no es un mapa oscuro peor existe el grafico.
    $game_player.iluminationScene.disposeAll
    $game_player.iluminationScene=nil
  end
}
class IlumScene
  
  MAXTIME  =  20 #Segundos en acabarse la barra entera.
  
  def initialize
    @bg=Sprite.new
    @bg.bitmap = Bitmap.new("Graphics/Pictures/Fondo")
    @bg.z=999999
    @gauge=Sprite.new
    @gauge.bitmap=Bitmap.new(Graphics.width,Graphics.height)
    @gauge.z=999999
    @maxframes=MAXTIME*Graphics.frame_rate
    @onSceneFrames=0
    @visible=true  # NUEVO: controlar visibilidad
  end
  def update
    #Actualización de la barra.
    @onSceneFrames+=1
    
    width=472-472*(@onSceneFrames/@maxframes.to_f)
    if width < 0; width = 0; end
    
    @gauge.bitmap.clear
    
    colors=
    @gauge.bitmap.fill_rect(20,21,width,10,Color.new(246,215,11))
    if width > 0 #Cuando se acaba...
      # NUEVO: asegurar que esté visible mientras hay tiempo
      if !@visible
        @bg.visible = true
        @gauge.visible = true
        @visible = true
      end
      
      if $PokemonTemp.darknessSprite && $PokemonTemp.darknessSprite.radius<176
        $PokemonTemp.darknessSprite.radius+=4
      end
      $PokemonGlobal.flashUsed=true
    else
      # NUEVO: ocultar cuando el tiempo llega a 0
      if @visible
        @bg.visible = false
        @gauge.visible = false
        @visible = false
      end
      
      if $PokemonTemp.darknessSprite && $PokemonTemp.darknessSprite.radius>64
        $PokemonTemp.darknessSprite.radius-=4
      end
      $PokemonGlobal.flashUsed=false
    end
  end
  
  def addToTimer(int)
    #Añade un número de segundos al contador.
    @onSceneFrames-=(int*Graphics.frame_rate)
    @onSceneFrames=0 if @onSceneFrames<0
    # NUEVO: mostrar la barra cuando se añade tiempo
    if @onSceneFrames < @maxframes && !@visible
      @bg.visible = true
      @gauge.visible = true
      @visible = true
    end
  end
  def disposeAll
    @bg.dispose if @bg
    @gauge.dispose if @gauge
  end
end
module Graphics
  #Actualización del Graphics.update para actualizar la barra a cada frame.
  #Mientras estas en el menú, el tiempo sigue contando (TO DO)
  class << self
    alias_method :old_update, :update
  end
  def self.update
    if $game_player && $game_player.iluminationScene 
      $game_player.iluminationScene.update
    end
    old_update
  end
end
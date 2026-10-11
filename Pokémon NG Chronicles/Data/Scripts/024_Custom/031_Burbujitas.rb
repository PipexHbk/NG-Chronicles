#===============================================================================
# # Klein Water Pond Bubbles for Pokémon Essentials
# # Give credits if you're using this!
# # http://kleinstudio.deviantart.com
#===============================================================================
# Terrain tag for Water Pond Bubbles, by default the one from reflected sprites
WATERPONDBUBBLE=PBTerrain::StillWater
WATERPONDBUBBLE2=PBTerrain::Water
WATERPONDBUBBLE3=PBTerrain::Reflection

class PondWaterBubble
  def initialize(event,position)
    return if !$scene || !$scene.is_a?(Scene_Map) ||
    event!=$game_player && (event.character_name=="" || 
    event.name.include?("/nowb/"))
    return if event!=$game_player && pbEventCommentInput(event,0,"NoWb")     
    character_sprites=$scene.spriteset.character_sprites
    viewport=$scene.spriteset.viewport1
    wbsprites=$scene.spriteset.wbsprites
    nid=getNewId
    fev=$game_map.events[nid]
    rpgEvent=RPG::Event.new(position[0],position[1])
    rpgEvent.id=nid       
    fev=Game_Event.new($game_map.map_id,rpgEvent,$game_map)
    eventsprite=Sprite_Character.new(viewport,fev)
    character_sprites.push(eventsprite) 
    wbsprites.push(PondWaterBubbleSprite.new(eventsprite,fev,viewport,
    $game_map,position[2],nid,character_sprites,(event==$game_player)))
  end
end

def getNewId
  newId = 1
  while $game_map.events[newId] != nil do 
    break if $game_map.events[newId].erased
    newId += 1
  end
  return newId
end
  
class Game_Event < Game_Character
  attr_reader :erased
end

class Sprite_Character
  alias old_initialize_wb initialize
  def initialize(viewport, character = nil)
    old_initialize_wb(viewport, character)
    @disposed=false
  end
  
  alias old_update_wb update
  def update
    return if @disposed
    old_update_wb
  end

  alias old_dispose_wb dispose
  def dispose
    old_dispose_wb
    @disposed=true
  end
end

class Spriteset_Map
  attr_accessor :character_sprites
  attr_accessor :wbsprites
    
  alias old_initialize_wb initialize
  def initialize(map=nil)
    old_initialize_wb(map)
    @wbsprites=[]
  end
  
  def putWaterBubble(event,pos)
    wb=PondWaterBubble.new(event,pos) 
  end
  
  alias old_dispose_wb dispose
  def dispose
    old_dispose_wb
    if @wbsprites!=nil
      for sprite in @wbsprites
        sprite.dispose
      end
    end
    @wbsprites.clear
  end
  
  alias old_update_wb update
  def update
    old_update_wb
    if @wbsprites!=nil
      for sprite in @wbsprites
        sprite.update 
      end
    end
  end
end

class Scene_Map
  def spriteset?
    return true if @spritesets!=nil
    return false
  end
end

class Game_Character
  alias old_increase_wb increase_steps
  
  def terrain_tag_pos(x=@x,y=@y)
    return $game_map.terrain_tag(x, y)
  end
  
  def increase_steps
    if terrain_tag_pos==WATERPONDBUBBLE || terrain_tag_pos==WATERPONDBUBBLE2 || terrain_tag_pos==WATERPONDBUBBLE3
      $scene.spriteset.putWaterBubble(self,[@x,@y,direction]) if $scene.is_a?(Scene_Map) &&
      $scene.spriteset?
    end
    old_increase_wb
  end
end

class PondWaterBubbleSprite
  def initialize(sprite,event,viewport,map,direction,nid,chardata,player)
    @rsprite=sprite
    @sprite=Sprite.new(viewport)
    @sprite.bitmap=BitmapCache.load_bitmap("Graphics/Pictures/waterpondbubble")
    @actualframe=-2
    @count=0
    @frames=@sprite.bitmap.width/@sprite.bitmap.height
    @width=@sprite.bitmap.height
    @sprite.src_rect.width=@width
    pbDayNightTint(@sprite)
    @event=event
    @disposed=false
    @map=map
    @eventid=nid
    @viewport=viewport
    @chardata=chardata
    @sprite.visible=false
    update
  end
  
  def updateAnimation
    @count+=1
    if @count==6
      if @actualframe<@frames
        @actualframe+=1
        @sprite.src_rect.x=@actualframe*@width
        @sprite.visible=true if @actualframe>=0
      end
      @count=0
    end
  end
  
  def dispose
    if !@disposed
     @disposed=true
     @event.erase
     for i in 0...@chardata.length
       @chardata.delete_at(i) if @chardata[i]==@rsprite
     end
     @rsprite.dispose
     @sprite.dispose 
     @sprite=nil
    end
  end
 
  def update 
    return if @disposed 
    updateAnimation
    x=@rsprite.x-@rsprite.ox
    y=@rsprite.y-@rsprite.oy
    width=@rsprite.src_rect.width
    height=@rsprite.src_rect.height
    @sprite.x=x+width/2
    @sprite.y=y+height
    @sprite.ox=@width/2
    @sprite.oy=@sprite.bitmap.height
    @sprite.z=@rsprite.z-1
    if @actualframe>=@frames
      dispose
    end
  end
end
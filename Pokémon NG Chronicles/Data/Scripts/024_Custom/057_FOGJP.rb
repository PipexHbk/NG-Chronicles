#===============================================================================
# Joiplay FOG Fix
# Corrige el escalado de fogs en dispositivos móviles
#===============================================================================

class Spriteset_Map
  alias joiplay_fog_fix_initialize initialize
  def initialize(map = nil)
    joiplay_fog_fix_initialize(map)
    fix_fog_for_joiplay
  end
  
  alias joiplay_fog_fix_update update
  def update
    joiplay_fog_fix_update
    fix_fog_zoom
  end
  
  def fix_fog_for_joiplay
    return if !@viewport3
    
    # Desactivar zoom del fog
    @viewport3.rect.set(0, 0, Graphics.width, Graphics.height) rescue nil
    
    # Ajustar el tamaño del fog al tamaño de la pantalla
    if @fog_bitmap && @fog_bitmap.respond_to?(:zoom_x)
      @fog_bitmap.zoom_x = 1.0
      @fog_bitmap.zoom_y = 1.0
    end
  end
  
  def fix_fog_zoom
    return if !@fog_bitmap
    
    # Mantener el zoom en 1.0 siempre
    if @fog_bitmap.respond_to?(:zoom_x)
      if @fog_bitmap.zoom_x != 1.0 || @fog_bitmap.zoom_y != 1.0
        @fog_bitmap.zoom_x = 1.0
        @fog_bitmap.zoom_y = 1.0
      end
    end
  end
end

puts "Joiplay FOG Fix cargado"
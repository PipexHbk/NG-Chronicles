#===============================================================================
# Mega Evolution Animation - Versión Final Pulida
# Para Essentials 16
#===============================================================================

module MegaEvoAnimNew
  GRAPHICS_PATH = "Graphics/Pictures/MegaEvoScene/"
  
  # Configuración de sonidos
  USE_SOUND_EFFECTS = true
  SE_TRANSFORM = "PRSFX- Mega Evolution1"     # SE durante transformación
  SE_REVEAL = "PRSFX- Mega Evolution2"        # SE cuando se revela la mega
  
  #-----------------------------------------------------------------------------
  # Animación completa de mega evolución
  #-----------------------------------------------------------------------------
  def self.play(pokemon)
    # Guardar música actual
    @previous_bgm = $game_system.getPlayingBGM
    
    # Crear viewport
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    
    @sprites = {}
    @middlex = Graphics.width / 2
    @middley = Graphics.height / 2
    
    PBDebug.log("[MegaAnim] === INICIANDO ANIMACIÓN COMPLETA ===")
    
    # === FASE 1: BASE + POKÉMON (SPRITE ANIMADO CENTRADO) ===
    create_sprite("base", "Base")
    center_sprite("base")
    
    # Crear sprite animado del Pokémon CENTRADO
    @sprites["pkmn"] = PokemonSprite.new(@viewport)
    @sprites["pkmn"].setPokemonBitmap(pokemon, false)  # false = frontal
    
    # Centrar el sprite del Pokémon
    if @sprites["pkmn"].bitmap
      @sprites["pkmn"].ox = @sprites["pkmn"].bitmap.width / 2
      @sprites["pkmn"].oy = @sprites["pkmn"].bitmap.height / 2
    end
    @sprites["pkmn"].x = @middlex
    @sprites["pkmn"].y = @middley
    @sprites["pkmn"].z = @viewport.z + 1
    
    # Fade in
    @sprites["base"].opacity = 0
    @sprites["pkmn"].opacity = 0
    
    20.times do
      @sprites["base"].opacity += 13
      @sprites["pkmn"].opacity += 13
      @sprites["pkmn"].update if @sprites["pkmn"].respond_to?(:update)
      Graphics.update
    end
    
    # Grito del Pokémon
    pbPlayCry(pokemon) if !pokemon.isEgg?
    pbWait(15)
    
    # Mantener animación del sprite
    10.times do
      @sprites["pkmn"].update if @sprites["pkmn"].respond_to?(:update)
      Graphics.update
    end
    
    # === FASE 2: ÍCONO MEGA APARECE ===
    create_sprite("icon", "icon_mega")
    center_sprite("icon")
    @sprites["icon"].y -= 80
    @sprites["icon"].zoom_x = 0.5
    @sprites["icon"].zoom_y = 0.5
    @sprites["icon"].opacity = 0
    @sprites["icon"].z = @viewport.z + 2
    
    # Fade in + zoom del ícono
    15.times do |i|
      @sprites["icon"].opacity += 17
      zoom = 0.5 + (i * 0.1)
      @sprites["icon"].zoom_x = zoom
      @sprites["icon"].zoom_y = zoom
      @sprites["pkmn"].update if @sprites["pkmn"].respond_to?(:update)
      Graphics.update
    end
    
    # Mantener ícono visible
    20.times do
      @sprites["pkmn"].update if @sprites["pkmn"].respond_to?(:update)
      Graphics.update
    end
    
    # Fade out del ícono
    15.times do
      @sprites["icon"].opacity -= 17
      @sprites["pkmn"].update if @sprites["pkmn"].respond_to?(:update)
      Graphics.update
    end
    @sprites["icon"].visible = false
    
    # === FASE 3: BURBUJAS APARECEN ===
    create_bubbles
    
    10.times do
      @sprites["pkmn"].update if @sprites["pkmn"].respond_to?(:update)
      Graphics.update
    end
    
    # === FASE 4: SONIDO + CÍRCULO CRECE + BURBUJAS CONVERGEN ===
    create_sprite("circle", "Circle")
    center_sprite("circle")
    @sprites["circle"].zoom_x = 0
    @sprites["circle"].zoom_y = 0
    @sprites["circle"].opacity = 200
    @sprites["circle"].z = @viewport.z + 1
    
    # Sonido de transformación
    pbSEPlay(SE_TRANSFORM) if USE_SOUND_EFFECTS
    
    # Animación simultánea: círculo crece + burbujas convergen
    25.times do |i|
      # Círculo crece
      zoom = i * 0.12
      @sprites["circle"].zoom_x = zoom
      @sprites["circle"].zoom_y = zoom
      
      # Burbujas se mueven hacia el centro
      @bubble_data.each do |data|
        start_x, start_y, bubble_i = data
        progress = (i + 1) / 25.0
        
        current_x = start_x + (@middlex - start_x) * progress
        current_y = start_y + (@middley - start_y) * progress
        
        @sprites["bubble#{bubble_i}"].x = current_x
        @sprites["bubble#{bubble_i}"].y = current_y
        @sprites["bubble#{bubble_i}"].opacity = 255 - (progress * 255).to_i
      end
      
      @sprites["pkmn"].update if @sprites["pkmn"].respond_to?(:update)
      Graphics.update
      pbWait(2)
    end
    
    # Ocultar burbujas
    16.times { |i| @sprites["bubble#{i}"].visible = false }
    
    # === FASE 5: EXPLOSIÓN DE LUZ ===
    @sprites["pkmn"].color = Color.new(255, 255, 255, 255)
    
    create_sprite("light", "Light")
    setup_spritesheet("light", 3)
    center_sprite("light")
    @sprites["light"].z = @viewport.z + 2
    
    create_sprite("circle2", "Circle 2")
    setup_spritesheet("circle2", 3)
    center_sprite("circle2")
    @sprites["circle2"].z = @viewport.z + 2
    
    # Animación de explosión
    zoom = 1.0
    3.times do |frame|
      animate_spritesheet("circle2", frame, 3)
      animate_spritesheet("light", frame, 3)
      
      zoom += 0.3
      @sprites["circle2"].zoom_x = zoom
      @sprites["circle2"].zoom_y = zoom
      @sprites["light"].zoom_x = zoom
      @sprites["light"].zoom_y = zoom
      
      Graphics.update
      pbWait(8)
    end
    
    # Flash blanco
    @sprites["flash"] = Sprite.new(@viewport)
    @sprites["flash"].bitmap = Bitmap.new(Graphics.width, Graphics.height)
    @sprites["flash"].bitmap.fill_rect(0, 0, Graphics.width, Graphics.height, Color.new(255, 255, 255))
    @sprites["flash"].opacity = 0
    @sprites["flash"].z = @viewport.z + 10
    
    15.times do
      @sprites["flash"].opacity += 17
      Graphics.update
    end
    
    # Ocultar todo EXCEPTO base, flash y pkmn (que se actualizará)
    @sprites.each do |key, sprite|
      if key != "flash" && key != "base" && key != "pkmn"
        sprite.visible = false
      end
    end
    
    pbWait(10)
    
    PBDebug.log("[MegaAnim] Fase 1 completada - Esperando transformación real...")
  end
  
  #-----------------------------------------------------------------------------
  # Animación final (después de la mega evolución)
  #-----------------------------------------------------------------------------
  def self.finish(pokemon)
    PBDebug.log("[MegaAnim] === REVELANDO MEGA EVOLUCIÓN ===")
    
    # Sonido de revelación
    pbSEPlay(SE_REVEAL) if USE_SOUND_EFFECTS
    
    # === FASE 6: SPRITE BASE DESAPARECE, MEGA APARECE EN SU LUGAR ===
    
    # Desvanecer el flash para revelar
    15.times do
      @sprites["flash"].opacity -= 17
      Graphics.update
    end
    
    # OCULTAR sprite de forma base
    @sprites["pkmn"].visible = false
    
    # CREAR NUEVO sprite MEGA ANIMADO en el mismo lugar
    @sprites["pkmn_mega"] = PokemonSprite.new(@viewport)
    @sprites["pkmn_mega"].setPokemonBitmap(pokemon, false)  # Ahora en forma Mega
    
    # Centrar el sprite Mega
    if @sprites["pkmn_mega"].bitmap
      @sprites["pkmn_mega"].ox = @sprites["pkmn_mega"].bitmap.width / 2
      @sprites["pkmn_mega"].oy = @sprites["pkmn_mega"].bitmap.height / 2
    end
    @sprites["pkmn_mega"].x = @middlex
    @sprites["pkmn_mega"].y = @middley
    @sprites["pkmn_mega"].z = @viewport.z + 1
    @sprites["pkmn_mega"].opacity = 0
    
    # Fade in del Pokémon Mega
    20.times do
      @sprites["pkmn_mega"].opacity += 13
      @sprites["pkmn_mega"].update if @sprites["pkmn_mega"].respond_to?(:update)
      Graphics.update
    end
    
    # Grito del Pokémon Mega
    pbPlayCry(pokemon) if !pokemon.isEgg?
    pbWait(10)
    
    # === MOSTRAR SPRITE MEGA ANIMADO POR 2 SEGUNDOS (120 frames) ===
    120.times do
      @sprites["pkmn_mega"].update if @sprites["pkmn_mega"].respond_to?(:update)
      Graphics.update
    end
    
    # === FASE 7: TRANSICIÓN BLANCA - BASE + MEGA DESAPARECEN ===
    @sprites["flash"].opacity = 0
    
    # Fade out de Base + Mega + Fade in de Flash (simultáneo)
    20.times do
      @sprites["flash"].opacity += 13
      @sprites["base"].opacity -= 13
      @sprites["pkmn_mega"].opacity -= 13
      @sprites["pkmn_mega"].update if @sprites["pkmn_mega"].respond_to?(:update)
      Graphics.update
    end
    
    # Flash blanco total
    pbWait(10)
    
    # Fade out del flash para volver a la batalla
    20.times do
      @sprites["flash"].opacity -= 13
      Graphics.update
    end
    
    # === LIMPIEZA FINAL ===
    dispose_all
    
    PBDebug.log("[MegaAnim] === ANIMACIÓN COMPLETADA ===")
  end
  
  #-----------------------------------------------------------------------------
  # Métodos auxiliares
  #-----------------------------------------------------------------------------
  
  def self.create_sprite(name, filename, blank = false)
    @sprites[name] = Sprite.new(@viewport)
    
    if blank
      return
    end
    
    path = GRAPHICS_PATH + filename
    
    if pbResolveBitmap(path)
      @sprites[name].bitmap = RPG::Cache.load_bitmap("", path)
      PBDebug.log("[MegaAnim] ✓ #{filename}")
    else
      @sprites[name].bitmap = Bitmap.new(32, 32)
      @sprites[name].visible = false
      PBDebug.log("[MegaAnim] ✗ NO ENCONTRADO: #{filename}")
    end
  end
  
  def self.center_sprite(name)
    return if !@sprites[name] || !@sprites[name].bitmap
    @sprites[name].ox = @sprites[name].bitmap.width / 2
    @sprites[name].oy = @sprites[name].bitmap.height / 2
    @sprites[name].x = @middlex
    @sprites[name].y = @middley
  end
  
  def self.setup_spritesheet(name, frames)
    return if !@sprites[name] || !@sprites[name].bitmap
    frame_width = @sprites[name].bitmap.width / frames
    @sprites[name].src_rect.width = frame_width
    @sprites[name].ox = frame_width / 2
    @sprites[name].oy = @sprites[name].bitmap.height / 2
    @sprites[name].x = @middlex
    @sprites[name].y = @middley
  end
  
  def self.animate_spritesheet(name, frame, total_frames)
    return if !@sprites[name] || !@sprites[name].bitmap
    frame_width = @sprites[name].bitmap.width / total_frames
    @sprites[name].src_rect.x = frame_width * frame
  end
  
  def self.create_bubbles
    @bubble_data = []
    
    16.times do |i|
      create_sprite("bubble#{i}", "Buble Pink")
      
      # Posición inicial en esquinas
      case i
      when 0..3
        x = @middlex / 2 - rand(30)
        y = @middley / 2 - rand(30)
      when 4..7
        x = @middlex / 2 - rand(30)
        y = @middley * 1.5 + rand(30)
      when 8..11
        x = @middlex * 1.5 + rand(30)
        y = @middley / 2 - rand(30)
      else
        x = @middlex * 1.5 + rand(30)
        y = @middley * 1.5 + rand(30)
      end
      
      @sprites["bubble#{i}"].x = x
      @sprites["bubble#{i}"].y = y
      @sprites["bubble#{i}"].ox = @sprites["bubble#{i}"].bitmap.width / 2 if @sprites["bubble#{i}"].bitmap
      @sprites["bubble#{i}"].oy = @sprites["bubble#{i}"].bitmap.height / 2 if @sprites["bubble#{i}"].bitmap
      @sprites["bubble#{i}"].z = @viewport.z + 1
      
      @bubble_data.push([x, y, i])
    end
  end
  
  def self.dispose_all
    @sprites.each_value do |sprite|
      if sprite.respond_to?(:dispose)
        sprite.bitmap.dispose if sprite.bitmap && sprite.bitmap.respond_to?(:dispose)
        sprite.dispose
      end
    end
    @sprites.clear
    @viewport.dispose if @viewport
  end
end
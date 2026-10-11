class PokeBattle_Scene
  
  alias assBackdrop pbBackdrop unless method_defined?(:assBackdrop)
  alias assAnimation pbAnimation

  def pbBackdrop
    assBackdrop()
    @sprites["bg2"] = Sprite.new(@viewport)
    @sprites["bg2"].visible = false
    @sprites["bg3"] = Sprite.new(@viewport)
    @sprites["bg3"].visible = false
  end
  
  def pbAnimation(id,attacker,opponent,hitnum=0)
    case id
    when PBMoves::MISTYTERRAIN
      pbDrawField()
    when PBMoves::PSYCHICTERRAIN
      pbDrawField()
    when PBMoves::GRASSYTERRAIN
      pbDrawField()
    when PBMoves::ELECTRICTERRAIN
      pbDrawField()  
    else
      assAnimation(id,attacker,opponent,hitnum)
    end
  end

  def sceneWait(numframes)
    numframes.times do
      pbGraphicsUpdate
      pbFrameUpdate
      Input.update
    end
  end
  
  # ———————————
  # Fading NO bloqueante (ver punto 2)
  # ———————————

  # En lugar de animar aquí, solo marcamos bandera de fade.
  def pbDeleteField
    return unless @sprites["bg2"]
    return unless @sprites["bg2"].visible
    @field_fade_frames = 32
  end

  def pbDrawField
    # Si estaba en fade, lo cancelamos antes de dibujar otro campo
    @field_fade_frames = 0 if @field_fade_frames && @field_fade_frames > 0
    pbDeleteField  # borra lo anterior si estaba visible (con el nuevo sistema no bloqueante)

    field = nil
    sound = nil

    if @battle.field.effects[PBEffects::GrassyTerrain] > 0
      field = "GrassyTerrain"
      sound = "PRSFX- Grassy Terrain"
    elsif @battle.field.effects[PBEffects::MistyTerrain] > 0
      field = "MistyTerrain"
      sound = "PRSFX- Misty Terrain"
    elsif @battle.field.effects[PBEffects::PsychicTerrain] > 0
      field = "PsychicTerrain"
      sound = "PRSFX- Psychic Terrain"
    elsif @battle.field.effects[PBEffects::ElectricTerrain] > 0
      field = "ElectricTerrain"
      sound = "PRSFX- Electric Terrain"
    end

    return if field.nil?

    @sprites["bg2"].bitmap = RPG::Cache.load_bitmap("Graphics/Animations/", field)
    @sprites["bg2"].opacity = 0
    @sprites["bg2"].visible = true
    pbSEPlay(sound, 80)

    # Fade-in no bloqueante: 32 pasos programados
    @field_fadein_frames = 32
  end

  # Extensión de pbGraphicsUpdate para procesar fades sin recursión
  alias assGraphicsUpdate pbGraphicsUpdate rescue nil
  def pbGraphicsUpdate
    assGraphicsUpdate() if defined?(assGraphicsUpdate)

    # Fade-in por pasos (no bloqueante)
    if @field_fadein_frames && @field_fadein_frames > 0 && @sprites["bg2"] && @sprites["bg2"].visible
      if @sprites["bg2"].bitmap && !@sprites["bg2"].bitmap.disposed?
        @sprites["bg2"].opacity += 8
      end
      @field_fadein_frames -= 1
      @field_fadein_frames = 0 if @sprites["bg2"].opacity >= 255
    end

    # Fade-out por pasos (no bloqueante)
    if @field_fade_frames && @field_fade_frames > 0 && @sprites["bg2"] && @sprites["bg2"].visible
      if @sprites["bg2"].bitmap && !@sprites["bg2"].bitmap.disposed?
        @sprites["bg2"].opacity -= 8
      end
      @field_fade_frames -= 1
      if @field_fade_frames <= 0
        @sprites["bg2"].visible = false
        if @sprites["bg2"].bitmap && !@sprites["bg2"].bitmap.disposed?
          @sprites["bg2"].bitmap.dispose rescue nil
        end
        @sprites["bg2"].bitmap = nil
        @field_fade_frames = 0
      end
    end
  end

end

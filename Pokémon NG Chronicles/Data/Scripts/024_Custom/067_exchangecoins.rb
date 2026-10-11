def pbCoinExchangeMachine
  viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
  viewport.z=999899
  sprites={}
  
  sprites["overlay"]=BitmapSprite.new(Graphics.width, Graphics.height, viewport)
  sprites["overlay"].z=100000
  
  loop do
    Graphics.update
    Input.update
    
    # Dibujar recuadros con fichas y dinero
    overlay=sprites["overlay"].bitmap
    overlay.clear
    baseColor=Color.new(255,255,255)
    shadowColor=Color.new(0,0,0)
    pbSetSystemFont(sprites["overlay"].bitmap)
    
    # Recuadro de fichas (esquina superior izquierda)
    overlay.fill_rect(10, 10, 160, 70, Color.new(0,0,0))
    overlay.fill_rect(12, 12, 156, 66, Color.new(0,180,0))
    
    # Recuadro de dinero (debajo del de fichas)
    overlay.fill_rect(10, 90, 160, 70, Color.new(0,0,0))
    overlay.fill_rect(12, 92, 156, 66, Color.new(0,180,0))
    
    textPositions=[
      [_INTL("Fichas:"), 20, 20, 0, baseColor, shadowColor],
      [_INTL("{1}",$PokemonGlobal.coins.to_i), 20, 50, 0, baseColor, shadowColor],
      [_INTL("Dinero:"), 20, 100, 0, baseColor, shadowColor],
      [_INTL("${1}",$Trainer.money), 20, 130, 0, baseColor, shadowColor]
    ]
    pbDrawTextPositions(overlay,textPositions)
    
    # Menu de opciones
    cmd=Kernel.pbMessage(_INTL("¿Cuántas fichas quieres cambiar?"),[
                          _INTL("1 ficha"),
                          _INTL("10 fichas"),
                          _INTL("100 fichas"),
                          _INTL("500 fichas"),
                          _INTL("1.000 fichas"),
                          _INTL("2.000 fichas"),
                          _INTL("5.000 fichas"),
                          _INTL("10.000 fichas"),
                          _INTL("Salir")],-1)
    
    # Array con valores de fichas y dinero correspondiente
    valores=[
      [1, 20],
      [10, 200],
      [100, 2000],
      [500, 10000],
      [1000, 20000],
      [2000, 40000],
      [5000, 100000],
      [10000, 200000]
    ]
    
    if cmd == 8  # Opción Salir
      pbFadeOutAndHide(sprites){pbUpdateSpriteHash(sprites)}
      pbDisposeSpriteHash(sprites)
      viewport.dispose if viewport
      return
    elsif cmd >= 0 && cmd < 8
      fichas_a_cambiar = valores[cmd][0]
      dinero_a_obtener = valores[cmd][1]
      
      # Verificar si tiene suficientes fichas
      if $PokemonGlobal.coins.to_i >= fichas_a_cambiar
        pbChangeCoins(-fichas_a_cambiar.to_i)
        $Trainer.money += dinero_a_obtener
        pbSEPlay("Mart buy item")
        Kernel.pbMessage(_INTL("Has cambiado {1} fichas por ${2}.",fichas_a_cambiar,dinero_a_obtener))
        pbWait(15)
      else
        Kernel.pbMessage(_INTL("No tienes suficientes fichas."))
        pbWait(15)
      end
    end
  end
end
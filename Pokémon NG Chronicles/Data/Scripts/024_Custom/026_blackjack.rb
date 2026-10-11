def pbBlackJack
  viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
  viewport.z=999899
  sprites={}
  
  # Variables del juego
  robo = 0
  turno = 0
  totalJ = 0
  totalR = 0
  cartasR = []
  apuesta = 0
  juegoActivo = true
  
  # Preguntar apuesta inicial
  apuestaCmd=Kernel.pbMessage(_INTL("¿Cuántas fichas quieres apostar?"),[
                          _INTL("250 fichas"),
                          _INTL("500 fichas"),
                          _INTL("1000 fichas")],-1)
  
  case apuestaCmd
  when 0
    apuesta = 250
  when 1
    apuesta = 500
  when 2
    apuesta = 1000
  else
    return
  end
  
  if $PokemonGlobal.coins < apuesta
    Kernel.pbMessage(_INTL("No tienes suficientes fichas para apostar."))
    return
  end
  
  sprites["bg"]=Sprite.new
  sprites["bg"].z=99999
  sprites["bg"].bitmap= BitmapCache.load_bitmap("Graphics/Pictures/BlackJack/background")
  
  sprites["cartaPlayer"]=IconSprite.new(0,0,viewport)
  sprites["cartaPlayer"].setBitmap("Graphics/Pictures/BlackJack/0_0")
  sprites["cartaPlayer"].x =224
  sprites["cartaPlayer"].y =220
  
  sprites["cartaRival"]=IconSprite.new(0,0,viewport)
  sprites["cartaRival"].setBitmap("Graphics/Pictures/BlackJack/CartaVol")
  sprites["cartaRival"].x =224
  sprites["cartaRival"].y =80
  
  sprites["overlay"]=BitmapSprite.new(Graphics.width, Graphics.height, viewport)
  sprites["overlay"].z=100000
  
  # Inicializar con una carta cada uno
  robo = rand(9)
  sprites["cartaPlayer"].setBitmap("Graphics/Pictures/BlackJack/1_#{robo}")
  if robo == 0
    valor=Kernel.pbMessage(_INTL("Tienes un As, ¿qué valor le das?"),[
                      _INTL("1"),
                      _INTL("11")],-1)
    totalJ = (valor == 0) ? 1 : 11
  else
    totalJ = robo + 1
  end
  
  # Casa roba su primera carta
  robo = rand(9)
  cartasR.push(robo)
  totalR = robo + 1
  
  # Casa roba su segunda carta (boca abajo)
  robo = rand(9)
  cartasR.push(robo)
  
  loop do
    Graphics.update
    Input.update
    
    overlay=sprites["overlay"].bitmap
    overlay.clear
    baseColor=Color.new(255,255,255)
    shadowColor=Color.new(0,0,0)
    pbSetSystemFont(sprites["overlay"].bitmap)
    
    # Dibujar recuadro para jugador (esquina inferior izquierda, fuera de la caja de texto)
    overlay.fill_rect(10, Graphics.height-150, 80, 50, Color.new(0,0,0))
    overlay.fill_rect(12, Graphics.height-148, 76, 46, Color.new(0,180,0))
    
    # Dibujar recuadro para casa (esquina superior derecha)
    overlay.fill_rect(Graphics.width-90, 10, 80, 50, Color.new(0,0,0))
    overlay.fill_rect(Graphics.width-88, 12, 76, 46, Color.new(0,180,0))
    
    textPositions=[
      [_INTL("{1}",totalJ), 20, Graphics.height-140, 0, baseColor, shadowColor],
      [_INTL("{1}",totalR), Graphics.width-80, 20, 0, baseColor, shadowColor]
    ]
    pbDrawTextPositions(overlay,textPositions)
    
    if juegoActivo
      cmd=Kernel.pbMessage(_INTL("¿Quieres robar una carta?"),[
                            _INTL("Sí"),
                            _INTL("No")],-1)
      if cmd==0 
        robo = rand(9)
        sprites["cartaPlayer"].setBitmap("Graphics/Pictures/BlackJack/1_#{robo}")
        if robo == 0
          valor=Kernel.pbMessage(_INTL("Tienes un As, ¿qué valor le das?"),[
                            _INTL("1"),
                            _INTL("11")],-1)
          robo = (valor == 0) ? 0 : 10
        end
        totalJ += robo + 1
        pbWait(15)
        
        if totalJ > 21
          Kernel.pbMessage(_INTL("¡Te pasaste de 21! ¡Has perdido!"))
          pbChangeCoins(-apuesta.to_i)
          pbMEPlay("Voltorb Flip Game Over")
          Kernel.pbMessage(_INTL("¡Has perdido <b>{1} fichas</b>!",apuesta))
          pbFadeOutAndHide(sprites){pbUpdateSpriteHash(sprites)}
          pbDisposeSpriteHash(sprites)
          viewport.dispose if viewport
          return false
        end
      else
        juegoActivo = false
        Kernel.pbMessage(_INTL("Te plantaste. Ahora la casa roba cartas."))
        pbWait(15)
        
        # Revelar segunda carta de la casa
        cartasR[1] = cartasR[1]
        if cartasR[0] == 0
          totalR = 11 + (cartasR[1] + 1)
        else
          totalR = (cartasR[0] + 1) + (cartasR[1] + 1)
        end
        
        Kernel.pbMessage(_INTL("La casa revela su segunda carta. Total: {1}",totalR))
        pbWait(20)
        
        # Casa roba hasta tener 17 o más, O hasta superar al jugador
        while totalR < 17 && totalR <= totalJ
          pbWait(20)
          robo = rand(9)
          cartasR.push(robo)
          totalR += robo + 1
          Kernel.pbMessage(_INTL("La casa roba una carta. Total: {1}",totalR))
          pbWait(20)
        end
        
        Kernel.pbMessage(_INTL("La casa se planta con {1}.",totalR))
        pbWait(15)
        
        # Determinar ganador
        if totalR > 21
          pbMEPlay("SlotsWin")
          recompensa = apuesta * 2
          pbChangeCoins(recompensa.to_i)
          Kernel.pbMessage(_INTL("¡La casa se pasó! ¡Has ganado!"))
          Kernel.pbMessage(_INTL("¡Has ganado <b>{1} fichas</b>!",recompensa))
        elsif totalJ == 21 && totalJ > totalR
          recompensa = (apuesta * 1.5).to_i
          pbChangeCoins(recompensa.to_i)
          pbMEPlay("SlotsWin")
          Kernel.pbMessage(_INTL("¡21 Blackjack! ¡Has ganado!"))
          Kernel.pbMessage(_INTL("¡Has ganado <b>{1} fichas</b> (x1.5)!",recompensa))
        elsif totalJ > totalR
          pbMEPlay("SlotsWin")
          recompensa = apuesta * 2
          pbChangeCoins(recompensa.to_i)
          Kernel.pbMessage(_INTL("¡Has ganado!"))
          Kernel.pbMessage(_INTL("¡Has ganado <b>{1} fichas</b>!",recompensa))
        else
          pbMEPlay("Voltorb Flip Game Over")
          # Si la casa tiene 21, pierdes x1.5
          if totalR == 21
            perdida = (apuesta * 1.5).to_i
            pbChangeCoins(-perdida.to_i)
            Kernel.pbMessage(_INTL("¡La casa tiene 21! ¡Has perdido!"))
            Kernel.pbMessage(_INTL("¡Has perdido <b>{1} fichas</b> (x1.5)!",perdida))
          else
            pbChangeCoins(-apuesta.to_i)
            Kernel.pbMessage(_INTL("¡Has perdido!"))
            Kernel.pbMessage(_INTL("¡Has perdido <b>{1} fichas</b>!",apuesta))
          end
        end
        
        pbFadeOutAndHide(sprites){pbUpdateSpriteHash(sprites)}
        pbDisposeSpriteHash(sprites)
        viewport.dispose if viewport
        return true
      end
    end
  end
end
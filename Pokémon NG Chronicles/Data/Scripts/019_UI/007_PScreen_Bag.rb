#===============================================================================
# Pantalla de la Mochila
#===============================================================================
class Window_PokemonBag < Window_DrawableCommand
  attr_reader :pocket
  attr_reader :sortIndex

  def initialize(bag,pocket,x,y,width,height)
    @bag=bag
    @pocket=pocket
    @sortIndex=-1
    @adapter=PokemonMartAdapter.new
    super(x,y,width,height)
    @selarrow=AnimatedBitmap.new("Graphics/#{BAG_ROUTE}/bagSel")
    self.windowskin=nil
  end

  def pocket=(value)
    @pocket=value
    thispocket=@bag.pockets[@pocket]
    @item_max=thispocket.length+1
    self.index=@bag.getChoice(@pocket)
    refresh
  end

def sortIndex=(value)
    # Bloqueado - No hacer nada
  end

  def page_row_max; return PokemonBag_Scene::ITEMSVISIBLE; end
  def page_item_max; return PokemonBag_Scene::ITEMSVISIBLE; end

  def itemRect(item)
    if item<0 || item>=@item_max || item<self.top_item-1 ||
       item>self.top_item+self.page_item_max
      return Rect.new(0,0,0,0)
    else
      cursor_width = (self.width-self.borderX-(@column_max-1)*@column_spacing) / @column_max
      x = item % @column_max * (cursor_width + @column_spacing)
      y = item / @column_max * @row_height - @virtualOy
      return Rect.new(x, y, cursor_width, @row_height)
    end
  end

  def drawCursor(index,rect)
    if self.index==index
      pbCopyBitmap(self.contents,@selarrow.bitmap,rect.x,rect.y+14)
    end
    return Rect.new(rect.x+16,rect.y+16,rect.width-16,rect.height)
  end

  def item
    thispocket=@bag.pockets[self.pocket]
    item=thispocket[self.index]
    return item ? item[0] : 0
  end

  def itemCount
    return @bag.pockets[self.pocket].length+1
  end

  def drawItem(index,count,rect)
    textpos=[]
    rect=drawCursor(index,rect)
    ypos=rect.y+4
    if index==@bag.pockets[self.pocket].length
      textpos.push([_INTL("CERRAR LA MOCHILA"),rect.x,ypos,false,
         self.baseColor,self.shadowColor])
    else
      item=@bag.pockets[self.pocket][index][0]
      itemname=@adapter.getDisplayName(item)
      qty=_ISPRINTF("x{1: 2d}",@bag.pockets[self.pocket][index][1])
      sizeQty=self.contents.text_size(qty).width
      xQty=rect.x+rect.width-sizeQty-16
baseColor=self.baseColor
shadowColor=self.shadowColor
      textpos.push([itemname,rect.x,ypos,false,baseColor,shadowColor])
      if !pbIsImportantItem?(item) # Not a Key item or HM (or infinite TM)
        textpos.push([qty,xQty,ypos,false,baseColor,shadowColor])
      end
    end
    pbDrawTextPositions(self.contents,textpos)
    if index!=@bag.pockets[self.pocket].length
      i = @bag.registeredItem.index(@bag.pockets[self.pocket][index][0]) 
      if i
        pbDrawImagePositions(self.contents,[
           [sprintf("Graphics/#{BAG_ROUTE}/bagReg#{i}"),rect.x+rect.width-58,ypos+4,0,0,-1,-1]
        ])
      end
    end
  end

  def refresh
    @item_max=itemCount()
    dwidth=self.width-self.borderX
    dheight=self.height-self.borderY
    self.contents=pbDoEnsureBitmap(self.contents,dwidth,dheight)
    self.contents.clear
    for i in 0...@item_max
      if i<self.top_item-1 || i>self.top_item+self.page_item_max
        next
      end
      drawItem(i,@item_max,itemRect(i))
    end
  end
end



class PokemonBag_Scene
## Configuration
  ITEMLISTBASECOLOR     = Color.new(88,88,80)
  ITEMLISTSHADOWCOLOR   = Color.new(168,184,184)
  ITEMTEXTBASECOLOR     = Color.new(248,248,248)
  ITEMTEXTSHADOWCOLOR   = Color.new(0,0,0)
  POCKETNAMEBASECOLOR   = Color.new(88,88,80)
  POCKETNAMESHADOWCOLOR = Color.new(168,184,184)
  ITEMSVISIBLE          = 7

  def update
    pbUpdateSpriteHash(@sprites)
  end

  def pbStartScene(bag)
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    @bag=bag
    @sprites={}
    lastpocket=@bag.lastpocket
    lastitem=@bag.getChoice(lastpocket)
    @sprites["background"]=IconSprite.new(0,0,@viewport)
    @sprites["background"].setBitmap(sprintf("Graphics/#{BAG_ROUTE}/bagbg#{lastpocket}"))
    @sprites["leftarrow"]=AnimatedSprite.new("Graphics/Pictures/leftarrow",8,40,28,2,@viewport)
    @sprites["rightarrow"]=AnimatedSprite.new("Graphics/Pictures/rightarrow",8,40,28,2,@viewport)
    @sprites["leftarrow"].play
    @sprites["rightarrow"].play
    @sprites["bag"]=IconSprite.new(30,20,@viewport)
    @sprites["icon"]=ItemIconSprite.new(48,Graphics.height-48,-1,@viewport)
    @sprites["itemwindow"]=Window_PokemonBag.new(@bag,lastpocket,168,-8,314,40+32+ITEMSVISIBLE*32)
    @sprites["itemwindow"].viewport=@viewport
    @sprites["itemwindow"].pocket=lastpocket
    @sprites["itemwindow"].index=lastitem
    @sprites["itemwindow"].baseColor=ITEMLISTBASECOLOR
    @sprites["itemwindow"].shadowColor=ITEMLISTSHADOWCOLOR
    @sprites["itemwindow"].refresh
    @sprites["slider"]=IconSprite.new(Graphics.width-40,60,@viewport)
    @sprites["slider"].setBitmap(sprintf("Graphics/#{BAG_ROUTE}/bagSlider"))
    @sprites["pocketwindow"]=BitmapSprite.new(186,228,@viewport)
    pbSetSystemFont(@sprites["pocketwindow"].bitmap)
    @sprites["itemtextwindow"]=Window_UnformattedTextPokemon.new("")
    @sprites["itemtextwindow"].x=72
    @sprites["itemtextwindow"].y=270
    @sprites["itemtextwindow"].width=Graphics.width-72
    @sprites["itemtextwindow"].height=128
    @sprites["itemtextwindow"].baseColor=ITEMTEXTBASECOLOR
    @sprites["itemtextwindow"].shadowColor=ITEMTEXTSHADOWCOLOR
    @sprites["itemtextwindow"].visible=true
    @sprites["itemtextwindow"].viewport=@viewport
    @sprites["itemtextwindow"].windowskin=nil
    @sprites["helpwindow"]=Window_UnformattedTextPokemon.new("")
    @sprites["helpwindow"].visible=false
    @sprites["helpwindow"].viewport=@viewport
    @sprites["msgwindow"]=Window_AdvancedTextPokemon.new("")
    @sprites["msgwindow"].visible=false
    @sprites["msgwindow"].viewport=@viewport
    pbBottomLeftLines(@sprites["helpwindow"],1)
    pbDeactivateWindows(@sprites)
    pbRefresh
    pbFadeInAndShow(@sprites)
  end
  
  def pbEndScene
    pbFadeOutAndHide(@sprites)
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end

  def pbChooseNumber(helptext,maximum)
    return UIHelper.pbChooseNumber(
       @sprites["helpwindow"],helptext,maximum) { update }
  end

  def pbDisplay(msg,brief=false)
    UIHelper.pbDisplay(@sprites["msgwindow"],msg,brief) { update }
  end

  def pbConfirm(msg)
    UIHelper.pbConfirm(@sprites["msgwindow"],msg) { update }
  end

  def pbShowCommands(helptext,commands)
    return UIHelper.pbShowCommands(
       @sprites["helpwindow"],helptext,commands) { update }
  end

  def pbRefresh
    bm=@sprites["pocketwindow"].bitmap
    bm.clear
    # Set the background bitmap for the currently selected pocket
    @sprites["background"].setBitmap(sprintf("Graphics/#{BAG_ROUTE}/bagbg#{@bag.lastpocket}"))
    # Set the bag picture for the currently selected pocket
    fbagexists=pbResolveBitmap(sprintf("Graphics/#{BAG_ROUTE}/bag#{@bag.lastpocket}f"))
    if $Trainer.isFemale? && fbagexists
      @sprites["bag"].setBitmap("Graphics/#{BAG_ROUTE}/bag#{@bag.lastpocket}f")
    else
      @sprites["bag"].setBitmap("Graphics/#{BAG_ROUTE}/bag#{@bag.lastpocket}")
    end
    # Draw the pocket name
    name=PokemonBag.pocketNames()[@bag.lastpocket]
    base=POCKETNAMEBASECOLOR
    shadow=POCKETNAMESHADOWCOLOR
    pbDrawTextPositions(bm,[
       [name,bm.width/2,180,2,base,shadow]
    ])
    # Reset positions of left/right arrows around the bag
    @sprites["leftarrow"].x=-4
    @sprites["leftarrow"].y=76
    @sprites["rightarrow"].x=150
    @sprites["rightarrow"].y=76
    itemwindow=@sprites["itemwindow"]
    # Draw the slider
    ycoord=60
    if itemwindow.itemCount>1
      ycoord+=116.0 * itemwindow.index/(itemwindow.itemCount-1)
    end
    @sprites["slider"].y=ycoord
    # Set the icon for the currently selected item
    @sprites["icon"].item=itemwindow.item
    # Display the item's description
if itemwindow.item==0
      @sprites["itemtextwindow"].text=_INTL("Cerrar la mochila.")
    else
      itemdesc = pbGetMessage(MessageTypes::ItemDescriptions,itemwindow.item)
      @sprites["itemtextwindow"].text = itemdesc
    end
    # Refresh the item window
    itemwindow.refresh
  end

  # ============================================
  # MÃ‰TODOS DE BÃšSQUEDA
  # ============================================
  def pbSearchItems
    # Abrir ventana de bÃºsqueda
    searchText = pbMessageFreeText(_INTL("Buscar objeto:"), "", false, 20, Graphics.width)
    return if !searchText || searchText == ""
    
    searchText = searchText.upcase
    
    # Crear array temporal con resultados
    @searchResults = []
    
    # Buscar en todos los bolsillos
    for pocket in 1..PokemonBag.numPockets
      thispocket = @bag.pockets[pocket]
      for i in 0...thispocket.length
        itemID = thispocket[i][0]
        itemName = PBItems.getName(itemID).upcase
        
        # Si el nombre contiene el texto buscado
        if itemName.include?(searchText)
          @searchResults.push([pocket, i, itemID, thispocket[i][1]])
        end
      end
    end
    
    # Mostrar resultados
    if @searchResults.length == 0
      pbDisplay(_INTL("No se encontraron objetos con '{1}'.", searchText))
      return
    end
    
    pbDisplaySearchResults(searchText)
  end

  def pbDisplaySearchResults(searchText)
    # Crear ventana de resultados
    commands = []
    for result in @searchResults
      itemName = PBItems.getName(result[2])
      pocketName = PokemonBag.pocketNames()[result[0]]
      commands.push(_INTL("{1} ({2})", itemName, pocketName))
    end
    commands.push(_INTL("Cancelar"))
    
    choice = pbShowCommands(_INTL("Resultados de '{1}':", searchText), commands)
    
    if choice >= 0 && choice < @searchResults.length
      # Ir al objeto seleccionado
      selectedResult = @searchResults[choice]
      @sprites["itemwindow"].pocket = selectedResult[0]
      @bag.lastpocket = selectedResult[0]
      @sprites["itemwindow"].index = selectedResult[1]
      @bag.setChoice(selectedResult[0], selectedResult[1])
      pbRefresh
    end
    
    @searchResults = []
  end
  # ============================================  
  
# ============================================
  # VER DETALLES DEL OBJETO
  # ============================================
  def pbShowItemDetails(item)
    return if item == 0
    
    # Obtener informaciÃ³n del objeto
    itemname = PBItems.getName(item)
    itemdesc = pbGetMessage(MessageTypes::ItemDescriptions, item)
    
    # Precio (si es vendible)
    price = pbGetPrice(item)
    pricetext = (price > 0) ? _INTL("Precio de venta: ${1}", (price / 2)) : _INTL("No se puede vender")
    
    # Construir texto completo con precio CENTRADO
    detailtext = _INTL("<ac><c2=43F022A8>{1}</c2></ac>\n", itemname)
    detailtext += _INTL("<ac><c2=F0784210>{1}</c2></ac>\n\n", pricetext)
    detailtext += itemdesc
    
    # Ocultar ventanas temporalmente
    @sprites["itemwindow"].visible = false
    @sprites["itemtextwindow"].visible = false
    @sprites["pocketwindow"].visible = false
    @sprites["icon"].visible = false
    @sprites["bag"].visible = false
    @sprites["leftarrow"].visible = false
    @sprites["rightarrow"].visible = false
    @sprites["slider"].visible = false
    
    # Crear fondo semitransparente
    @sprites["detailoverlay"] = IconSprite.new(0, 0, @viewport)
    @sprites["detailoverlay"].z = 99999
    overlaybitmap = Bitmap.new(Graphics.width, Graphics.height)
    overlaybitmap.fill_rect(0, 0, Graphics.width, Graphics.height, Color.new(0, 0, 0, 180))
    @sprites["detailoverlay"].bitmap = overlaybitmap
    @sprites["detailoverlay"].visible = true
    
    # Crear ventana de detalles
    @sprites["detailwindow"] = Window_AdvancedTextPokemon.new(detailtext)
    @sprites["detailwindow"].viewport = @viewport
    @sprites["detailwindow"].width = Graphics.width - 40
    @sprites["detailwindow"].height = Graphics.height - 80
    @sprites["detailwindow"].x = 20
    @sprites["detailwindow"].y = 40
    @sprites["detailwindow"].z = 100000
    @sprites["detailwindow"].visible = true
    
    # Crear icono del objeto DENTRO de la ventana (tamaÃ±o normal)
    # PosiciÃ³n: esquina superior izquierda de la ventana + margen
    @sprites["detailicon"] = ItemIconSprite.new(
      @sprites["detailwindow"].x + 16,  # 16px de margen desde el borde izquierdo
      @sprites["detailwindow"].y + 16,  # 16px de margen desde el borde superior
      item, 
      @viewport
    )
    @sprites["detailicon"].z = 100001  # Por encima de la ventana
    # TamaÃ±o normal (sin zoom)
    
    # Esperar input del jugador
    loop do
      Graphics.update
      Input.update
      @sprites["detailwindow"].update
      @sprites["detailicon"].update if @sprites["detailicon"]
      
      # Cerrar ventana
      if Input.trigger?(Input::C) || Input.trigger?(Input::B)
        pbPlayCloseMenuSE()
        break
      end
    end
    
    # Limpiar sprites de detalles
    if @sprites["detailwindow"]
      @sprites["detailwindow"].dispose
      @sprites.delete("detailwindow")
    end
    
    if @sprites["detailicon"]
      @sprites["detailicon"].dispose
      @sprites.delete("detailicon")
    end
    
    if @sprites["detailoverlay"]
      @sprites["detailoverlay"].bitmap.dispose if @sprites["detailoverlay"].bitmap
      @sprites["detailoverlay"].dispose
      @sprites.delete("detailoverlay")
    end
    
    # Restaurar ventanas
    @sprites["itemwindow"].visible = true
    @sprites["itemtextwindow"].visible = true
    @sprites["pocketwindow"].visible = true
    @sprites["icon"].visible = true
    @sprites["bag"].visible = true
    @sprites["leftarrow"].visible = true
    @sprites["rightarrow"].visible = true
    @sprites["slider"].visible = true
  end
  
def pbChooseItem(lockpocket=false)
  pbRefresh
  @sprites["helpwindow"].visible=false
  itemwindow=@sprites["itemwindow"]
  itemwindow.refresh
  itemwindow.active=true
   
  loop do
    Graphics.update
    Input.update
    
    # Detectar Input::Y PRIMERO
    if Input.trigger?(Input::Y)
      if itemwindow.item != 0
        pbPlayDecisionSE()
        pbShowItemDetails(itemwindow.item)
        pbRefresh
        next
      end
    end    
    
    olditem=itemwindow.item
    oldindex=itemwindow.index
    
    # ACTUALIZAR SOLO CURSOR SIN PROCESAR INPUTS
    if Input.trigger?(Input::UP)
      itemwindow.index-=1
      itemwindow.index=itemwindow.itemCount-1 if itemwindow.index<0
    elsif Input.trigger?(Input::DOWN)
      itemwindow.index+=1
      itemwindow.index=0 if itemwindow.index>=itemwindow.itemCount
    end
    
    self.update
    
    if itemwindow.item!=olditem
      ycoord=60
      if itemwindow.itemCount>1
        ycoord+=116.0 * itemwindow.index/(itemwindow.itemCount-1)
      end
      @sprites["slider"].y=ycoord
      @sprites["icon"].item=itemwindow.item
      if itemwindow.item==0
        @sprites["itemtextwindow"].text=_INTL("Cerrar la mochila.")
      else
        itemdesc = pbGetMessage(MessageTypes::ItemDescriptions,itemwindow.item)
        @sprites["itemtextwindow"].text = itemdesc
      end
    end
    
    if itemwindow.index!=oldindex
      @bag.setChoice(itemwindow.pocket,itemwindow.index)
    end
    
    if !lockpocket
      numpockets=PokemonBag.numPockets
      if Input.trigger?(Input::LEFT)
        itemwindow.pocket=(itemwindow.pocket==1) ? numpockets : itemwindow.pocket-1
        @bag.lastpocket=itemwindow.pocket
        pbRefresh
      elsif Input.trigger?(Input::RIGHT)
        itemwindow.pocket=(itemwindow.pocket==numpockets) ? 1 : itemwindow.pocket+1
        @bag.lastpocket=itemwindow.pocket
        pbRefresh
      end
    end
    
    if Input.trigger?(Input::B)
      itemwindow.active=false
      return 0
    end
    
    # Input::A abre menú de acciones (usar, dar, tirar, etc.)
    if Input.trigger?(Input::A)
      thispocket=@bag.pockets[itemwindow.pocket]
      if itemwindow.index<thispocket.length
        pbRefresh
        itemwindow.active=false
        return thispocket[itemwindow.index][0]
      else
        itemwindow.active=false
        return 0
      end
    end
    
    # Input::C NO HACE NADA - Bloqueado para evitar conflictos
    if Input.trigger?(Input::C)
      # Consumir el input sin hacer nada
    end
  end
end
end

class PokemonBagScreen
  def initialize(scene,bag)
    @bag=bag
    @scene=scene
  end

  def pbDisplay(text)
    @scene.pbDisplay(text)
  end

  def pbConfirm(text)
    return @scene.pbConfirm(text)
  end

# UI logic for the item screen when an item is to be held by a PokÃ©mon.
  def pbGiveItemScreen
    @scene.pbStartScene(@bag)
    item=0
    loop do
      item=@scene.pbChooseItem
      break if item==0
      itemname=PBItems.getName(item)
      # Key items and hidden machines can't be held
      if pbIsImportantItem?(item)
        @scene.pbDisplay(_INTL("{1} no puede ser llevado.",itemname))
        next
      else
        break
      end
    end
    @scene.pbEndScene
    return item
  end

# UI logic for the item screen when an item is used on a PokÃ©mon from the party screen.
  def pbUseItemScreen(pokemon)
    @scene.pbStartScene(@bag)
    item=0
    loop do
      item=@scene.pbChooseItem
      break if item==0
      itemname=PBItems.getName(item)
      # Can't use certain items on PokÃ©mon
      if !ItemHandlers.hasUseOnPokemon(item) && !pbIsMachine?(item)
        @scene.pbDisplay(_INTL("{1} no puede usarse en {2}.",itemname,pokemon.name))
        next
      else
        break
      end
    end
    @scene.pbEndScene
    return item
  end

# UI logic for the item screen for choosing an item
  def pbChooseItemScreen
    oldlastpocket=@bag.lastpocket
    @scene.pbStartScene(@bag)
    item=@scene.pbChooseItem
    @scene.pbEndScene
    @bag.lastpocket=oldlastpocket
    return item
  end

# UI logic for the item screen for choosing a Berry
  def pbChooseBerryScreen
    oldlastpocket=@bag.lastpocket
    @bag.lastpocket=BERRYPOCKET
    @scene.pbStartScene(@bag)
    item=0
    loop do
      item=@scene.pbChooseItem(true)
      break if item==0
      itemname=PBItems.getName(item)
      if !pbIsBerry?(item)
        @scene.pbDisplay(_INTL("Eso no es una Baya.",itemname))
        next
      else
        break
      end
    end
    @scene.pbEndScene
    @bag.lastpocket=oldlastpocket
    return item
  end

# UI logic for tossing an item in the item screen.
  def pbTossItemScreen
    if !$PokemonGlobal.pcItemStorage
      $PokemonGlobal.pcItemStorage=PCItemStorage.new
    end
    storage=$PokemonGlobal.pcItemStorage
    @scene.pbStartScene(storage)
    loop do
      item=@scene.pbChooseItem
      break if item==0
      if pbIsImportantItem?(item)
        @scene.pbDisplay(_INTL("Â¡Eso es demasiado importante como para tirarlo!"))
        next
      end
      qty=storage.pbQuantity(item)
      itemname=PBItems.getName(item)
      itemnameplural=PBItems.getNamePlural(item)
      if qty>1
        qty=@scene.pbChooseNumber(_INTL("Â¿CuÃ¡ntas unidades de {1} quieres tirar?",itemnameplural),qty)
      end
      if qty>0
        itemname=itemnameplural if qty>1
        if pbConfirm(_INTL("Â¿Seguro que quieres tirar {1} {2}?",qty,itemname))
          if !storage.pbDeleteItem(item,qty)
            raise "Can't delete items from storage"
          end
          pbDisplay(_INTL("Â¡Has tirado {1} {2}!",qty,itemname))
        end
      end
    end
    @scene.pbEndScene
  end

# UI logic for withdrawing an item in the item screen.
  def pbWithdrawItemScreen
    if !$PokemonGlobal.pcItemStorage
      $PokemonGlobal.pcItemStorage=PCItemStorage.new
    end
    storage=$PokemonGlobal.pcItemStorage
    @scene.pbStartScene(storage)
    loop do
      item=@scene.pbChooseItem
      break if item==0
      commands=[_INTL("Retirar"),_INTL("Dar"),_INTL("Salir")]
      itemname=PBItems.getName(item)
      
      command=@scene.pbShowCommands(_INTL("Has seleccionado {1}.",itemname),commands)
      if command==0
        qty=storage.pbQuantity(item)
        if qty>1 && !pbIsImportantItem?(item)
          qty=@scene.pbChooseNumber(_INTL("Â¿CuÃ¡ntos quieres retirar?"),qty)
        end
        if qty>0
          dispqty=(pbIsImportantItem?(item)) ? 1 : qty
          itemname=PBItems.getNamePlural(item) if dispqty>1
          if !@bag.pbCanStore?(item,qty)
            pbDisplay(_INTL("No hay mÃ¡s espacio en la Mochila."))
          else
            pbDisplay(_INTL("Retiraste {1} {2}(s).",dispqty,itemname))
            if !storage.pbDeleteItem(item,qty)
              raise "No se pueden descartar objetos del almacenamiento"
            end
            if !@bag.pbStoreItem(item,qty)
              raise "No se pueden retirar objetos del almacenamiento"
            end
          end
        end
      elsif command==1 # Give
        if $Trainer.pokemonCount==0
          @scene.pbDisplay(_INTL("No hay PokÃ©mon."))
          return 0
        elsif pbIsImportantItem?(item)
          @scene.pbDisplay(_INTL("{1} no se puede llevar.",itemname))
        else
          pbFadeOutIn(99999){
             sscene=PokemonScreen_Scene.new
             sscreen=PokemonScreen.new(sscene,$Trainer.party)
             if sscreen.pbPokemonGiveScreen(item)
               # If the item was held, delete the item from storage
               if !storage.pbDeleteItem(item,1)
                 raise "No se puede descartar objeto del almacenamiento"
               end
             end
             @scene.pbRefresh
          }
        end
      end
    end
    @scene.pbEndScene
  end

# UI logic for depositing an item in the item screen.
  def pbDepositItemScreen
    @scene.pbStartScene(@bag)
    if !$PokemonGlobal.pcItemStorage
      $PokemonGlobal.pcItemStorage=PCItemStorage.new
    end
    storage=$PokemonGlobal.pcItemStorage
    item=0
    loop do
      item=@scene.pbChooseItem
      break if item==0
      qty=@bag.pbQuantity(item)
      if qty>1 && !pbIsImportantItem?(item)
        qty=@scene.pbChooseNumber(_INTL("Â¿CuÃ¡ntos quieres depositar?"),qty)
      end
      if qty>0
        if !storage.pbCanStore?(item,qty)
          pbDisplay(_INTL("No hay espacio para guardar objetos."))
        else
          dispqty=(pbIsImportantItem?(item)) ? 1 : qty
          itemname=(dispqty>1) ? PBItems.getNamePlural(item) : PBItems.getName(item)
          pbDisplay(_INTL("Se depositÃ³ {1} {2}(s).",dispqty,itemname))
          if !@bag.pbDeleteItem(item,qty)
            raise "No se pudieron borrar los objetos de la mochila"
          end
          if !storage.pbStoreItem(item,qty)
            raise "No se pudieron dejar los objetos de la mochila"
          end
        end
      end
    end
    @scene.pbEndScene
  end

  def pbStartScreen
    @scene.pbStartScene(@bag)
    item=0
    loop do
      item=@scene.pbChooseItem
      break if item==0
      cmdUse         = -1
      cmdRegister    = -1
      cmdGive        = -1
      cmdToss        = -1
      cmdRead        = -1
      cmdMysteryGift = -1
      cmdSearch      = -1  # <-- NUEVA LÃNEA
      commands=[]
      # Generate command list
      commands[cmdRead=commands.length]=_INTL("Leer") if pbIsMail?(item)
      commands[cmdUse=commands.length]=_INTL("Usar") if ItemHandlers.hasOutHandler(item) || (pbIsMachine?(item) && $Trainer.party.length>0)
      commands[cmdGive=commands.length]=_INTL("Dar") if $Trainer.pokemonParty.length>0 && !pbIsImportantItem?(item)
      commands[cmdToss=commands.length]=_INTL("Tirar") if !pbIsImportantItem?(item) || $DEBUG

      commands[cmdRegister=commands.length]=_INTL("Registrar") if pbIsKeyItem?(item) && ItemHandlers.hasKeyItemHandler(item)

      commands[cmdMysteryGift=commands.length]=_INTL("Hacer Reg. Mist.") if $DEBUG

      cmdSort = commands.length
      commands[cmdSort] = _INTL("Ordenar")
      cmdSearch = commands.length          # <-- NUEVA LÃNEA
      commands[cmdSearch] = _INTL("Buscar") # <-- NUEVA LÃNEA
      commands[commands.length] = _INTL("Salir")
      # Show commands generated above
      itemname=PBItems.getName(item) # Get item name
      command=@scene.pbShowCommands(_INTL("Has seleccionado {1}.",itemname),commands)
      if cmdUse>=0 && command==cmdUse # Use item
        ret=pbUseItem(@bag,item,@scene)
        # 0=Item wasn't used; 1=Item used; 2=Close Bag to use in field
        break if ret==2 # End screen
        @scene.pbRefresh
        next
      elsif cmdRead>=0 && command==cmdRead # Read mail
        pbFadeOutIn(99999){
           pbDisplayMail(PokemonMail.new(item,"",""))
        }
      elsif cmdRegister>=0 && command==cmdRegister # Register key item
        registerCommands = Input::ITEMKEYSNAMES + [_INTL("Back")]
        registerCommand = @scene.pbShowCommands(
            _INTL("Escoge una tecla.",itemname),registerCommands)
        @bag.pbRegisterKeyItem(item,registerCommand) if registerCommand!=-1 && registerCommand!=registerCommands.size
        @scene.pbRefresh
      elsif cmdGive>=0 && command==cmdGive # Give item to PokÃ©mon
        if $Trainer.pokemonCount==0
          @scene.pbDisplay(_INTL("No hay PokÃ©mon."))
        elsif pbIsImportantItem?(item)
          @scene.pbDisplay(_INTL("No se puede llevar {1}.",itemname))
        else
          # Give item to a PokÃ©mon
          pbFadeOutIn(99999){
             sscene=PokemonScreen_Scene.new
             sscreen=PokemonScreen.new(sscene,$Trainer.party)
             sscreen.pbPokemonGiveScreen(item)
             @scene.pbRefresh
          }
        end
      elsif cmdToss>=0 && command==cmdToss # Toss item
        qty=@bag.pbQuantity(item)
        if qty>1
          helptext=_INTL("Â¿CuÃ¡ntas unidades de {1} quieres tirar?",PBItems.getNamePlural(item))
          qty=@scene.pbChooseNumber(helptext,qty)
        end
        if qty>0
          itemname=PBItems.getNamePlural(item) if qty>1
          if pbConfirm(_INTL("Â¿Entonces quieres tirar {1} {2}?",qty,itemname))
            pbDisplay(_INTL("Se tiraron {1} {2}.",qty,itemname))
            qty.times { @bag.pbDeleteItem(item) }      
          end
        end   
      elsif cmdMysteryGift>=0 && command==cmdMysteryGift   # Export to Mystery Gift
        pbCreateMysteryGift(1,item)
        
        elsif cmdSort>=0 && command==cmdSort   # Ordenar objetos
  sort_options = [_INTL("AlfabÃ©ticamente"), _INTL("Por cantidad"), _INTL("Cancelar")]
  sort_choice = @scene.pbShowCommands(_INTL("Â¿CÃ³mo quieres ordenar los objetos?"), sort_options)
  case sort_choice
  when 0
    pbSortPocket(@bag.lastpocket, :alphabetical)
    @scene.pbRefresh
  when 1
    pbSortPocket(@bag.lastpocket, :quantity)
    @scene.pbRefresh
  end
  next
     elsif cmdSearch>=0 && command==cmdSearch
                @scene.pbSearchItems
                next
                  end
        end
    @scene.pbEndScene
    return item
  end
end



#===============================================================================
# The Bag object, which actually contains all the items
#===============================================================================
class PokemonBag
  attr_reader :registeredItem
  attr_accessor :lastpocket
  attr_reader :pockets

  def registeredItem
    # The below line is to this change don't mess with existing saves
    @registeredItem = [@registeredItem] if !@registeredItem.is_a?(Array) 
    while @registeredItem.size<Input::ITEMKEYS.size
      @registeredItem.push(nil)
    end
    return @registeredItem
  end
  
  def self.pocketNames()
    return pbPocketNames
  end

  def self.numPockets()
    return self.pocketNames().length-1
  end

  def initialize
    @lastpocket=1
    @pockets=[]
    @choices=[]
    # Initialize each pocket of the array
    for i in 0..PokemonBag.numPockets
      @pockets[i]=[]
      @choices[i]=0
    end
    @registeredItem=[]
  end

  def pockets
    rearrange
    return @pockets
  end

  def rearrange
    if (@pockets.length-1)!=PokemonBag.numPockets
      newpockets=[]
      for i in 0..PokemonBag.numPockets
        newpockets[i]=[]
        @choices[i]=0 if !@choices[i]
      end
      nump=PokemonBag.numPockets
      for i in 0...@pockets.length
        for item in @pockets[i]
          p=pbGetPocket(item[0])
          newpockets[p].push(item) if p<=nump
        end
      end
      @pockets=newpockets
    end
  end

# Gets the index of the current selected item in the pocket
  def getChoice(pocket)
    if pocket<=0 || pocket>PokemonBag.numPockets
      raise ArgumentError.new(_INTL("Bolsillo invÃ¡lido: {1}",pocket.inspect))
    end
    rearrange
    return [@choices[pocket],@pockets[pocket].length].min || 0
  end

# Clears the entire bag
  def clear
    for pocket in @pockets
      pocket.clear
    end
  end

# Sets the index of the current selected item in the pocket
  def setChoice(pocket,value)
    if pocket<=0 || pocket>PokemonBag.numPockets
      raise ArgumentError.new(_INTL("Bolsillo invÃ¡lido: {1}",pocket.inspect))
    end
    rearrange
    @choices[pocket]=value if value<=@pockets[pocket].length
  end

# Registers the item as a key item.  Can be retrieved with $PokemonBag.registeredItem
  def pbRegisterKeyItem(item,itemKeyNumber)
    if item.is_a?(String) || item.is_a?(Symbol)
      item=getID(PBItems,item)
    end
    if !item || item<1
      raise ArgumentError.new(_INTL("El nÃºmero de objeto no es vÃ¡lido."))
      return
    end
    index = registeredItem.index(item)
    registeredItem[index]=nil if index # remove duplicates
    registeredItem[itemKeyNumber]=item if !index || index!=itemKeyNumber
  end
  
  def maxPocketSize(pocket)
    maxsize=MAXPOCKETSIZE[pocket]
    return -1 if !maxsize
    return maxsize
  end

  def pbQuantity(item)
    if item.is_a?(String) || item.is_a?(Symbol)
      item=getID(PBItems,item)
    end
    if !item || item<1
      p ArgumentError.new(_INTL("El nÃºmero de objeto no es vÃ¡lido."))
      return 0
    end
    pocket=pbGetPocket(item)
    maxsize=maxPocketSize(pocket)
    maxsize=@pockets[pocket].length if maxsize<0
    return ItemStorageHelper.pbQuantity(@pockets[pocket],maxsize,item)
  end

  def pbHasItem?(item)
    return pbQuantity(item)>0
  end

  def pbDeleteItem(item,qty=1)
    if item.is_a?(String) || item.is_a?(Symbol)
      item=getID(PBItems,item)
    end
    if !item || item<1
      raise ArgumentError.new(_INTL("El nÃºmero de objeto no es vÃ¡lido."))
      return false
    end
    pocket=pbGetPocket(item)
    maxsize=maxPocketSize(pocket)
    maxsize=@pockets[pocket].length if maxsize<0
    ret=ItemStorageHelper.pbDeleteItem(@pockets[pocket],maxsize,item,qty)
    if ret
      index = registeredItem.index(item)
      registeredItem[index]=nil if index && !pbHasItem?(item)
    end
    return ret
  end

  def pbCanStore?(item,qty=1)
    if item.is_a?(String) || item.is_a?(Symbol)
      item=getID(PBItems,item)
    end
    if !item || item<1
      raise ArgumentError.new(_INTL("El nÃºmero de objeto no es vÃ¡lido."))
      return false
    end
    pocket=pbGetPocket(item)
    maxsize=maxPocketSize(pocket)
    maxsize=@pockets[pocket].length+1 if maxsize<0
    return ItemStorageHelper.pbCanStore?(
       @pockets[pocket],maxsize,BAGMAXPERSLOT,item,qty)
  end

  def pbStoreAllOrNone(item,qty=1)
    if item.is_a?(String) || item.is_a?(Symbol)
      item=getID(PBItems,item)
    end
    if !item || item<1
      raise ArgumentError.new(_INTL("El nÃºmero de objeto no es vÃ¡lido."))
      return false
    end
    pocket=pbGetPocket(item)
    maxsize=maxPocketSize(pocket)
    maxsize=@pockets[pocket].length+1 if maxsize<0
    return ItemStorageHelper.pbStoreAllOrNone(
       @pockets[pocket],maxsize,BAGMAXPERSLOT,item,qty)
  end

  def pbStoreItem(item,qty=1)
    if item.is_a?(String) || item.is_a?(Symbol)
      item=getID(PBItems,item)
    end
    if !item || item<1
      raise ArgumentError.new(_INTL("El nÃºmero de objeto no es vÃ¡lido."))
      return false
    end
    pocket=pbGetPocket(item)
    maxsize=maxPocketSize(pocket)
    maxsize=@pockets[pocket].length+1 if maxsize<0
    return ItemStorageHelper.pbStoreItem(
       @pockets[pocket],maxsize,BAGMAXPERSLOT,item,qty,true)
  end

  def pbChangeItem(olditem,newitem)
    if olditem.is_a?(String) || olditem.is_a?(Symbol)
      olditem=getID(PBItems,olditem)
    end
    if newitem.is_a?(String) || newitem.is_a?(Symbol)
      newitem=getID(PBItems,newitem)
    end
    if !olditem || olditem<1 || !newitem || newitem<1
      raise ArgumentError.new(_INTL("El nÃºmero de objeto no es vÃ¡lido."))
      return false
    end
    pocket=pbGetPocket(olditem)
    maxsize=maxPocketSize(pocket)
    maxsize=@pockets[pocket].length if maxsize<0
    ret=false
    for i in 0...maxsize
      itemslot=@pockets[pocket][i]
      if itemslot && itemslot[0]==olditem
        itemslot[0]=newitem
        ret=true
      end
    end
    return ret
  end
end



#===============================================================================
# PC item storage screen
#===============================================================================
class Window_PokemonItemStorage < Window_DrawableCommand
  attr_reader :bag
  attr_reader :pocket
  attr_reader :sortIndex

  def sortIndex=(value)
    @sortIndex=value
    refresh
  end

  def initialize(bag,x,y,width,height)
    @bag=bag
    @sortIndex=-1
    @adapter=PokemonMartAdapter.new
    super(x,y,width,height)
    self.windowskin=nil
  end

  def item
    item=@bag[self.index]
    return item ? item[0] : 0
  end

  def itemCount
    return @bag.length+1
  end

  def drawItem(index,count,rect)
    textpos=[]
    rect=drawCursor(index,rect)
    ypos=rect.y
    if index==@bag.length
      textpos.push([_INTL("SALIR"),rect.x,ypos,false,
         self.baseColor,self.shadowColor])
    else
      item=@bag[index][0]
      itemname=@adapter.getDisplayName(item)
      qty=_ISPRINTF("x{1: 2d}",@bag[index][1])
      sizeQty=self.contents.text_size(qty).width
      xQty=rect.x+rect.width-sizeQty-2
      baseColor=(index==@sortIndex) ? Color.new(248,24,24) : self.baseColor
      textpos.push([itemname,rect.x,ypos,false,self.baseColor,self.shadowColor])
      if !pbIsImportantItem?(item) # Not a Key item or HM (or infinite TM)
        textpos.push([qty,xQty,ypos,false,baseColor,self.shadowColor])
      end
    end
    pbDrawTextPositions(self.contents,textpos)
  end
end



class ItemStorageScene
## Configuration
  ITEMLISTBASECOLOR   = Color.new(88,88,80)
  ITEMLISTSHADOWCOLOR = Color.new(168,184,184)
  ITEMTEXTBASECOLOR   = Color.new(248,248,248)
  ITEMTEXTSHADOWCOLOR = Color.new(0,0,0)
  TITLEBASECOLOR      = Color.new(248,248,248)
  TITLESHADOWCOLOR    = Color.new(0,0,0)
  ITEMSVISIBLE        = 7

  def initialize(title)
    @title=title
  end

  def update
    pbUpdateSpriteHash(@sprites)
  end

  def pbStartScene(bag)
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    @bag=bag
    @sprites={}
    @sprites["background"]=IconSprite.new(0,0,@viewport)
    @sprites["background"].setBitmap("Graphics/#{PARTY_ROUTE}/pcItembg")
    @sprites["icon"]=ItemIconSprite.new(50,334,-1,@viewport)
    # Item list
    @sprites["itemwindow"]=Window_PokemonItemStorage.new(@bag,98,14,334,32+ITEMSVISIBLE*32)
    @sprites["itemwindow"].viewport=@viewport
    @sprites["itemwindow"].index=0
    @sprites["itemwindow"].baseColor=ITEMLISTBASECOLOR
    @sprites["itemwindow"].shadowColor=ITEMLISTSHADOWCOLOR
    @sprites["itemwindow"].refresh
    # Title
    @sprites["pocketwindow"]=BitmapSprite.new(88,64,@viewport)
    @sprites["pocketwindow"].x=14
    @sprites["pocketwindow"].y=16
    pbSetNarrowFont(@sprites["pocketwindow"].bitmap)
    # Item description  
    @sprites["itemtextwindow"]=Window_UnformattedTextPokemon.newWithSize("",84,270,Graphics.width-84,128,@viewport)
    @sprites["itemtextwindow"].baseColor=ITEMTEXTBASECOLOR
    @sprites["itemtextwindow"].shadowColor=ITEMTEXTSHADOWCOLOR
    @sprites["itemtextwindow"].windowskin=nil
    @sprites["helpwindow"]=Window_UnformattedTextPokemon.new("")
    @sprites["helpwindow"].visible=false
    @sprites["helpwindow"].viewport=@viewport
    # Letter-by-letter message window
    @sprites["msgwindow"]=Window_AdvancedTextPokemon.new("")
    @sprites["msgwindow"].visible=false
    @sprites["msgwindow"].viewport=@viewport
    pbBottomLeftLines(@sprites["helpwindow"],1)
    pbDeactivateWindows(@sprites)
    pbRefresh
    pbFadeInAndShow(@sprites)
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites)
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end

  def pbRefresh
    bm=@sprites["pocketwindow"].bitmap
    # Draw title at upper left corner ("Toss Item/Withdraw Item")
    drawTextEx(bm,0,0,bm.width,2,@title,TITLEBASECOLOR,TITLESHADOWCOLOR)
    itemwindow=@sprites["itemwindow"]
    # Draw item icon
    @sprites["icon"].item=itemwindow.item
    # Get item description
    @sprites["itemtextwindow"].text=(itemwindow.item==0) ? _INTL("Cerrar almacenamiento.") : 
       pbGetMessage(MessageTypes::ItemDescriptions,itemwindow.item)
    itemwindow.refresh
  end

  def pbChooseItem
    pbRefresh
    @sprites["helpwindow"].visible=false
    itemwindow=@sprites["itemwindow"]
    itemwindow.refresh
    pbActivateWindow(@sprites,"itemwindow"){
       loop do
         Graphics.update
         Input.update
         olditem=itemwindow.item
         self.update
         if itemwindow.item!=olditem
           self.pbRefresh
         end
         if Input.trigger?(Input::B)
           return 0
         end
         if Input.trigger?(Input::C) || Input.trigger?(Input::A)
           if itemwindow.index<@bag.length
             pbRefresh
             return @bag[itemwindow.index][0]
           else
             return 0
           end
         end
       end
    }
  end
  
  def pbChooseNumber(helptext,maximum)
    return UIHelper.pbChooseNumber(
       @sprites["helpwindow"],helptext,maximum) { update }
  end

  def pbDisplay(msg,brief=false)
    UIHelper.pbDisplay(@sprites["msgwindow"],msg,brief) { update }
  end

  def pbConfirm(msg)
    UIHelper.pbConfirm(@sprites["msgwindow"],msg) { update }
  end

  def pbShowCommands(helptext,commands)
    return UIHelper.pbShowCommands(
       @sprites["helpwindow"],helptext,commands) { update }
  end
end



class WithdrawItemScene < ItemStorageScene
  def initialize
    super(_INTL("Sacar<br>objeto"))
  end
end



class TossItemScene < ItemStorageScene
  def initialize
    super(_INTL("Tirar<br>objeto"))
  end
end



#===============================================================================
# The PC item storage object, which actually contains all the items
#===============================================================================
class PCItemStorage
  MAXSIZE    = 50    # Number of different slots in storage
  MAXPERSLOT = 999   # Max. number of items per slot

  def initialize
    @items=[]
    # Start storage with a Potion
    if hasConst?(PBItems,:POTION)
      ItemStorageHelper.pbStoreItem(
         @items,MAXSIZE,MAXPERSLOT,getConst(PBItems,:POTION),1)
    end
  end

  def empty?
    return @items.length==0
  end

  def length
    @items.length
  end

  def [](i)
    @items[i]
  end

  def getItem(index)
    if index<0 || index>=@items.length
      return 0
    else
      return @items[index][0]
    end
  end

  def getCount(index)
    if index<0 || index>=@items.length
      return 0
    else
      return @items[index][1]
    end
  end

  def pbQuantity(item)
    return ItemStorageHelper.pbQuantity(@items,MAXSIZE,item)
  end

  def pbDeleteItem(item,qty=1)
    return ItemStorageHelper.pbDeleteItem(@items,MAXSIZE,item,qty)
  end

  def pbCanStore?(item,qty=1)
    return ItemStorageHelper.pbCanStore?(@items,MAXSIZE,MAXPERSLOT,item,qty)
  end

  def pbStoreItem(item,qty=1)
    return ItemStorageHelper.pbStoreItem(@items,MAXSIZE,MAXPERSLOT,item,qty)
  end
end



#===============================================================================
# Common UI functions used in both the Bag and item storage screens.
# Allows the user to choose a number.  The window _helpwindow_ will
# display the _helptext_.
#===============================================================================
module UIHelper
  def self.pbChooseNumber(helpwindow,helptext,maximum)
    oldvisible=helpwindow.visible
    helpwindow.visible=true
    helpwindow.text=helptext
    helpwindow.letterbyletter=false
    curnumber=1
    ret=0
    using(numwindow=Window_UnformattedTextPokemon.new("x000")){
       numwindow.viewport=helpwindow.viewport
       numwindow.letterbyletter=false
       numwindow.text=_ISPRINTF("x{1:03d}",curnumber)
       numwindow.resizeToFit(numwindow.text,480)
       pbBottomRight(numwindow) # Move number window to the bottom right
       helpwindow.resizeHeightToFit(helpwindow.text,480-numwindow.width)
       pbBottomLeft(helpwindow) # Move help window to the bottom left
       loop do
         Graphics.update
         Input.update
         numwindow.update
         block_given? ? yield : helpwindow.update
         if Input.repeat?(Input::LEFT)
           curnumber-=10
           curnumber=1 if curnumber<1
           numwindow.text=_ISPRINTF("x{1:03d}",curnumber)
           pbPlayCursorSE()
         elsif Input.repeat?(Input::RIGHT)
           curnumber+=10
           curnumber=maximum if curnumber>maximum
           numwindow.text=_ISPRINTF("x{1:03d}",curnumber)
           pbPlayCursorSE()
         elsif Input.repeat?(Input::UP)
           curnumber+=1
           curnumber=1 if curnumber>maximum
           numwindow.text=_ISPRINTF("x{1:03d}",curnumber)
           pbPlayCursorSE()
         elsif Input.repeat?(Input::DOWN)
           curnumber-=1
           curnumber=maximum if curnumber<1
           numwindow.text=_ISPRINTF("x{1:03d}",curnumber)
           pbPlayCursorSE()
         elsif Input.trigger?(Input::C) || Input.trigger?(Input::A)
           ret=curnumber
           pbPlayDecisionSE()
           break
         elsif Input.trigger?(Input::B)
           ret=0
           pbPlayCancelSE()
           break
         end
       end
    }
    helpwindow.visible=oldvisible
    return ret
  end

  def self.pbDisplayStatic(msgwindow,message)
    oldvisible=msgwindow.visible
    msgwindow.visible=true
    msgwindow.letterbyletter=false
    msgwindow.width=Graphics.width
    msgwindow.resizeHeightToFit(message,Graphics.width)
    msgwindow.text=message
    pbBottomRight(msgwindow)
    loop do
      Graphics.update
      Input.update
      if Input.trigger?(Input::B)
        break
      end
      if Input.trigger?(Input::C) || Input.trigger?(Input::A)
        break
      end
      block_given? ? yield : msgwindow.update
    end
    msgwindow.visible=oldvisible
    Input.update
  end

# Letter by letter display of the message _msg_ by the window _helpwindow_.
  def self.pbDisplay(helpwindow,msg,brief)
    cw=helpwindow
    cw.letterbyletter=true
    cw.text=msg+"\1"
    pbBottomLeftLines(cw,2)
    oldvisible=cw.visible
    cw.visible=true
    loop do
      Graphics.update
      Input.update
      block_given? ? yield : cw.update
      if brief && !cw.busy?
        cw.visible=oldvisible
        return
      end
      if Input.trigger?(Input::C) || Input.trigger?(Input::A) && cw.resume && !cw.busy?
        cw.visible=oldvisible
        return
      end
    end
  end

# Letter by letter display of the message _msg_ by the window _helpwindow_,
# used to ask questions.  Returns true if the user chose yes, false if no.
  def self.pbConfirm(helpwindow,msg)
    dw=helpwindow
    oldvisible=dw.visible
    dw.letterbyletter=true
    dw.text=msg
    dw.visible=true
    pbBottomLeftLines(dw,2)
    commands=[_INTL("SÃ­"),_INTL("No")]
    cw = Window_CommandPokemon.new(commands)
    cw.viewport=helpwindow.viewport
    pbBottomRight(cw)
    cw.y-=dw.height
    cw.index=0
    loop do
      cw.visible=!dw.busy?
      Graphics.update
      Input.update
      cw.update
      block_given? ? yield : dw.update
      if Input.trigger?(Input::B) && dw.resume && !dw.busy?
        cw.dispose
        dw.visible=oldvisible
        pbPlayCancelSE()
        return false
      end
      if Input.trigger?(Input::C) || Input.trigger?(Input::A) && dw.resume && !dw.busy?
        cwIndex=cw.index
        cw.dispose
        dw.visible=oldvisible
        pbPlayDecisionSE()
        return (cwIndex==0)?true:false
      end
    end
  end

  def self.pbShowCommands(helpwindow,helptext,commands)
    ret=-1
    oldvisible=helpwindow.visible
    helpwindow.visible=helptext ? true : false
    helpwindow.letterbyletter=false
    helpwindow.text=helptext ? helptext : ""
    cmdwindow=Window_CommandPokemon.new(commands)
    begin
      cmdwindow.viewport=helpwindow.viewport
      pbBottomRight(cmdwindow)
      helpwindow.resizeHeightToFit(helpwindow.text,480-cmdwindow.width)
      pbBottomLeft(helpwindow)
      loop do
        Graphics.update
        Input.update
        yield
        cmdwindow.update
        if Input.trigger?(Input::B)
          ret=-1
          pbPlayCancelSE()
          break
        end
        if Input.trigger?(Input::C) || Input.trigger?(Input::A)
          ret=cmdwindow.index
          pbPlayDecisionSE()
          break
        end
      end
    ensure
      cmdwindow.dispose if cmdwindow
    end
    helpwindow.visible=oldvisible
    return ret
  end
end

################################################################################
# Implements methods that act on arrays of items.  Each element in an item
# array is itself an array of [itemID, itemCount].
# Used by the Bag, PC item storage, and Triple Triad.
################################################################################
module ItemStorageHelper
  # Returns the quantity of the given item in the items array, maximum size per slot, and item ID
  def self.pbQuantity(items,maxsize,item)
    ret=0
    for i in 0...maxsize
      itemslot=items[i]
      if itemslot && itemslot[0]==item
        ret+=itemslot[1]
      end
    end
    return ret
  end

  # Deletes an item from items array, maximum size per slot, item, and number of items to delete
  def self.pbDeleteItem(items,maxsize,item,qty)
    raise "Invalid value for qty: #{qty}" if qty<0
    return true if qty==0
    ret=false
    for i in 0...maxsize
      itemslot=items[i]
      if itemslot && itemslot[0]==item
        amount=[qty,itemslot[1]].min
        itemslot[1]-=amount
        qty-=amount
        items[i]=nil if itemslot[1]==0
        if qty==0
          ret=true
          break
        end
      end
    end
    items.compact!
    return ret
  end

  def self.pbCanStore?(items,maxsize,maxPerSlot,item,qty)
    raise "Invalid value for qty: #{qty}" if qty<0
    return true if qty==0
    for i in 0...maxsize
      itemslot=items[i]
      if !itemslot
        qty-=[qty,maxPerSlot].min
        return true if qty==0
      elsif itemslot[0]==item && itemslot[1]<maxPerSlot
        newamt=itemslot[1]
        newamt=[newamt+qty,maxPerSlot].min
        qty-=(newamt-itemslot[1])
        return true if qty==0
      end
    end
    return false
  end

  def self.pbStoreItem(items,maxsize,maxPerSlot,item,qty,sorting=false)
    raise "Invalid value for qty: #{qty}" if qty<0
    return true if qty==0
    for i in 0...maxsize
      itemslot=items[i]
      if !itemslot
        items[i]=[item,[qty,maxPerSlot].min]
        qty-=items[i][1]
        if sorting
          items.sort! if POCKETAUTOSORT[$ItemData[item][ITEMPOCKET]]
        end
        return true if qty==0
      elsif itemslot[0]==item && itemslot[1]<maxPerSlot
        newamt=itemslot[1]
        newamt=[newamt+qty,maxPerSlot].min
        qty-=(newamt-itemslot[1])
        itemslot[1]=newamt
        return true if qty==0
      end
    end
    return false
  end
end
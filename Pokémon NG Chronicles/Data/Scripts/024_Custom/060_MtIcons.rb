class PokemonBag_Scene

  alias pbStartScene_MT pbStartScene
  def pbStartScene(bag)
    pbStartScene_MT(bag)
    @datamove = load_data("Data/tm.dat")
    pbTM
  end
  
  def pbSpeciesCompatibleBag?(species,move)
    return false if species<0
    return false if !@datamove[move]
    return @datamove[move].any? {|item| item==species}
  end

  def pbTM 
    for i in 0...$Trainer.party.length
      if !@sprites["pokemon#{i}"]
        next if $Trainer.party[i].isEgg?
        @sprites["pokemon#{i}"]=PokemonIconSprite.new($Trainer.party[i],@viewport) 
        @sprites["pokemon#{i}"].x=13*2+40*2*(i&1)
        @sprites["pokemon#{i}"].y=6*2+25*2*(i/2)
      end
    end
  end  

  def pbTMmenu
    for i in 0...$Trainer.party.length
      next if $Trainer.party[i].isEgg?
      
      # CRÍTICO: Verificar que el sprite existe antes de acceder a él
      next if !@sprites["pokemon#{i}"]
      
      flag=false
      item=@sprites["itemwindow"].item
      lastpocket=@bag.lastpocket
      
      if $ItemData[item][ITEMPOCKET]==4
        machine=$ItemData[item][ITEMMACHINE]
        flag=pbSpeciesCompatibleBag?($Trainer.party[i].species,machine)
      end
      if lastpocket==4
        @sprites["pokemon#{i}"].visible=true
      end
      if @sprites["pokemon#{i}"].selected!=flag
        @sprites["pokemon#{i}"].selected=flag
        (flag) ? @sprites["pokemon#{i}"].x-=8 : @sprites["pokemon#{i}"].x+=8
      end
      gray=0
      gray=255 if !flag
      @sprites["pokemon#{i}"].tone=Tone.new(0,0,0,gray)
    end
    
    for i in 0...$Trainer.party.length
      # CRÍTICO: Verificar que el sprite existe antes de acceder a él
      next if !@sprites["pokemon#{i}"]
      
      lastpocket=@bag.lastpocket
      if lastpocket==1 || lastpocket==2 || lastpocket==3 || lastpocket==5 || 
         lastpocket==6 || lastpocket==7 || lastpocket==8 || lastpocket==9
        @sprites["pokemon#{i}"].visible=false
      end
    end
  end

  # Called when the item screen wants an item to be chosen from the screen
  def pbChooseItem(lockpocket=false)
    pbRefresh
    pbTM 
    @sprites["helpwindow"].visible=false
    itemwindow=@sprites["itemwindow"]
    itemwindow.refresh
    itemwindow.active=true
    sorting=false
    sortindex=-1
    pbTMmenu
    
    loop do
      Graphics.update
      Input.update
      
      # CRÍTICO: Detectar Input::Y PRIMERO
      if Input.trigger?(Input::Y)
        if itemwindow.item != 0
          pbPlayDecisionSE()
          pbShowItemDetails(itemwindow.item)
          pbRefresh
          pbTMmenu
          next
        end
      end
      
      olditem=itemwindow.item
      oldindex=itemwindow.index
      itemwindow.update
      # ELIMINADO: self.update (causa el salto doble)
      
      if itemwindow.item!=olditem
        ycoord=60
        if itemwindow.itemCount>1
          ycoord+=116.0 * itemwindow.index/(itemwindow.itemCount-1)
        end
        @sprites["slider"].y=ycoord
        @sprites["icon"].item=itemwindow.item
        @sprites["itemtextwindow"].text=(itemwindow.item==0) ? _INTL("Cerrar la mochila.") :
           pbGetMessage(MessageTypes::ItemDescriptions,itemwindow.item)
        pbTMmenu
      end
      
      if itemwindow.index!=oldindex
        @bag.setChoice(itemwindow.pocket,itemwindow.index)
      end
      
      if !lockpocket
        numpockets=PokemonBag.numPockets
        if Input.trigger?(Input::LEFT)
          if !sorting
            itemwindow.pocket=(itemwindow.pocket==1) ? numpockets : itemwindow.pocket-1
            @bag.lastpocket=itemwindow.pocket
            pbTMmenu 
            pbRefresh
          end
        elsif Input.trigger?(Input::RIGHT)
          if !sorting
            itemwindow.pocket=(itemwindow.pocket==numpockets) ? 1 : itemwindow.pocket+1
            @bag.lastpocket=itemwindow.pocket
            pbTMmenu
            pbRefresh
          end
        end
      end
      
      if Input.trigger?(Input::A)
        thispocket=@bag.pockets[itemwindow.pocket]
        if itemwindow.index<thispocket.length && thispocket.length>1 &&
           !POCKETAUTOSORT[itemwindow.pocket]
          sortindex=itemwindow.index
          sorting=true
          @sprites["itemwindow"].sortIndex=sortindex
        else
          next
        end
      end
      
      if Input.trigger?(Input::B)
        if sorting
          sorting=false
          @sprites["itemwindow"].sortIndex=-1
        else
          itemwindow.active=false
          return 0
        end
      end
      
      if Input.trigger?(Input::C)
        thispocket=@bag.pockets[itemwindow.pocket]
        if itemwindow.index<thispocket.length
          if sorting
            sorting=false
            tmp=thispocket[itemwindow.index]
            thispocket[itemwindow.index]=thispocket[sortindex]
            thispocket[sortindex]=tmp
            @sprites["itemwindow"].sortIndex=-1
            pbRefresh
            next
          else
            pbRefresh
            itemwindow.active=false
            return thispocket[itemwindow.index][0]
          end
        else
          itemwindow.active=false
          return 0
        end
      end
    end
  end
end
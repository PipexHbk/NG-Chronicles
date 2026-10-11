ItemHandlers::UseFromBag.add(:DIPLOMA,proc{|item|
   s=Sprite.new()
   s.bitmap=Bitmap.new("Graphics/Pictures/diploma")
   s.z=99999
   loop{Input.update;Graphics.update
     if Input.trigger?(Input::C)
       pbFadeOutIn(99999){s.dispose}
       break
     end  
   }
   next 1
})
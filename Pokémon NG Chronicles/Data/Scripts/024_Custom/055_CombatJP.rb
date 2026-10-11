#===============================================================================
# Joiplay Combat Fix - FINAL
#===============================================================================
module JoiplayCombatFix
  def self.cleanBeforeBattle
    3.times do
      GC.start
      Graphics.update
    end
  end
  
  def self.cleanAfterBattle
    SpriteCache.clear if defined?(SpriteCache)
    5.times do
      GC.start
      Graphics.update
      sleep(0.2)
    end
  end
  
  def self.deepClean
    SpriteCache.clear if defined?(SpriteCache)
    BitmapCache.clear if defined?(BitmapCache.clear)
    
    5.times do
      GC.start
      Graphics.update
      sleep(0.3)
    end
  end
end
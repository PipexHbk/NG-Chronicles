def pbUpdateMax(level)
  redef_without_warning(:MAXIMUMLEVEL,level)
  PBExperience.redef_without_warning(:MAXLEVEL,level)
end

class Object
  def def_if_not_defined(const, value)
    mod = self.is_a?(Module) ? self : self.class
    mod.const_set(const, value) unless mod.const_defined?(const)
  end
  
  def redef_without_warning(const, value)
    mod = self.is_a?(Module) ? self : self.class
    mod.send(:remove_const, const) if mod.const_defined?(const)
    mod.const_set(const, value)
  end
end
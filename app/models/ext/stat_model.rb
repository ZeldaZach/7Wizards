module Ext
  module StatModel
    def get_stat_value(name, default = nil)
      name = name.to_s
      self.stats && self.stats[name] ? self.stats[name] : default
    end

    def set_stat_value(name, value)
      name = name.to_s
      self.stats ||= {}
      self.stats[name] = value
    end
  end
end

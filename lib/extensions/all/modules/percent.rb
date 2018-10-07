module Extensions
  module All
    module Modules
      module Percent

        def to_percent
          self.to_f / 100
        end

        def percent_of(value)
          (self.to_f * value.to_f / 100)
        end 
        
      end
    end
  end
end

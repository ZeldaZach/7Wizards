module Extensions
  module All
    module Modules
      module Format
        def separate_upper
          self.capitalize.gsub(/(_[a-zA-Z])/).each do |i| i.upcase end
        end
      end
    end
  end
end

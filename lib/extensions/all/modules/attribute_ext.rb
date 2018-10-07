module Extensions
  module All
    module Modules
      module AttributeExt

        def is_include_a?(clazz)
          if clazz.is_a? Array
            clazz.each { |clazz_item| return true if self.is_a? clazz_item  }
            false
          else
            self.is_a? clazz
          end
        end

      end
    end
  end
end


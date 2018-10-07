module Extensions
  module All
    module Modules
      module DateTimeExt
        def current_month?
          same_month? Time.now
        end

        def same_month?(value)
          self.year == value.year && self.month == value.month
        end

        def day_start
          t = Time.now
          Time.local(t.year, t.month, t.day)
        end

      end
    end
  end
end

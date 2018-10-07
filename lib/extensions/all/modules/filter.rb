module Extensions
  module All
    module Modules
      module Filter
        def cyr_latin_only
          self.gsub(/[^a-zA-Zа-яА-ЯёЁіІїЇ0-9\.\,\:\;\'\$\@\&\*\?\-\_\=\+\! \)\(\%\~\`]/i, "")
        end
      end
    end
  end
end

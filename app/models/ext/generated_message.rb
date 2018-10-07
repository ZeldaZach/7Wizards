module Ext
  module GeneratedMessage
  
    def g_title(view)
      parse_g_message view, self.title
    end

    def g_message(view)
      self.message ? parse_g_message(view, self.message) : nil
    end

    def parse_g_message(view, message)
      while m = message.match(/\[\[relation\_path\]\](\d*)/) do
        url = ''
        if !m[1].blank? # it can be blank in case of monster message
          if view.admin?
            url = '/admin/users/show/' + m[1]
          else
            url = '/relation/details/' + m[1]
          end
          url = view.url_for(url)
        end
        message = message.gsub(m[0], url)
      end
      while m = message.match(/\[\[clan\_path\]\](\d*)/) do
        url = '/clan/details/' + m[1]
        url = view.url_for(url)
        message = message.gsub(m[0], url)
      end
#      while m = message.match(/\[\[quest\_path\]\](\d*)/) do
#        url = '/game/quest/history_details/' + m[1]
#        url = view.url_for(url)
#        message = message.gsub(m[0], url)
#      end
#      while m = message.match(/\[\[icon\_([\w\_]*)\]\]/) do
#        tag = view.image_tag "icons/icon_#{m[1]}.gif"
#        message = message.gsub(m[0], tag)
#      end
      message
    end
  end
end

module BaseMessageModel

  def g_title(view)
    parse_g_message view, self.title
  end

  def g_message(view)
    self.message ? parse_g_message(view, self.message) : nil
  end

  def parse_g_message(view, message)
    while m = message.match(/\[\[relation\_path_(\d*)_(\w*)\]\]/) do
      url = ''
      if !m[1].blank? # it can be blank in case of monster message
        if view.admin?
          url = '/admin/users/show/' + m[1]
        else
          url = '/profile/index/' + m[1]
        end
        url = view.link_to_ajax(m[2], :url => url)
      end
      message = message.gsub(m[0], url)
    end
    while m = message.match(/\[\[clan\_path\_(\d*)_([\w 0-9]*)\]\]/) do
      url = view.link_to_ajax(m[2], :url => "/clan/details/#{m[1]}")
      message = message.gsub(m[0], url)
    end
    while m = message.match(/\[\[war\_path_(\d*)_(\w*)\]\]/) do
      url = view.link_to_ajax(m[2], :url => "/clan/wars/#{m[1]}")
      message = message.gsub(m[0], url)
    end
    while m = message.match(/\[\[quest\_path_(\d*)_(\w*)\]\]/) do
      url = '/game/quest/history_details/' + m[1]
      url = view.link_to_ajax(m[2], :url => "/quest/history_details#{m[1]}")
      message = message.gsub(m[0], url)
    end
    while m = message.match(/\[\[icon\_([\w\_]*)\]\]/) do
      tag = view.image_tag "icons/icon_#{m[1]}.gif"
      message = message.gsub(m[0], tag)
    end
    message
  end
  
end

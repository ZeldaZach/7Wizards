module Helpers
  module ChatHelper

    def chat_javascript
      user = current_user
      ban  = user.active_ban
      
      chat_options = {
        :chat_enabled   => GameProperties.is_enabled_mode?(:chat),
        :server_host    => request.host,
        :server_port    => ApeConfig.port,
        :smiles         => smiles_list,
        :nav_container  => "$('chat_messages_bottom_panel')",
        :msg_container  => "$('chat_messages_content_panel')",
        :user_container => "$('inner_scrolled_content')",
        :smile_container => "$('chat_smiles')",
        :rooms_container => "$('inner_rooms')",
        :avatar_container => "$('chat_user_avatar')",
        :error_container  => "$('chat_error_block')",
#        :base_avatar_url    => "/images/avatars/users",
        :amazone_avatar_url => "/images/avatars/users"#"#{Amazon.get_bucket_url(user)}"
      }

      user_options = {
        :user_id      => user.id,
        :user_name    => user.name,
        :user_level   => user.a_level,
        :clan_id      => user.clan_id,
        :gender       => user.gender,
        :avatar       => user.avatar,
        :is_moderator => user.is_moderator,
        :confirmed_email => user.confirmed_email,
        :blocked => ban && ban.only_messages,
        :blocked_reason => ban ? ban.public_reason : "",
        :session_id => 0 # TODO session.session_id
      }

      js = <<-JS
        Element.observe(window, 'load', function() {
          chat.initialize(#{!GameProperties::PROD}, #{chat_options.to_json}, #{user_options.to_json})
        })
      JS
      javascript_tag js
    end

    def smiles_list
      smiles = []
      GameProperties::CHAT_SMILEYS.each do |smiley, smiley_name|
        smiles << {:alt => smiley, :img => smiley_name}
      end
      smiles
    end

    #    def chat_link_to(options = {})
    #      options[:href]    ||= "javascript: void(0)"
    #      options[:href]    = "href=\'#{options[:href]}\'"
    #
    #      options[:id]      = "id=\'#{options[:id]}\'" if options[:id]
    #      options[:uid]     = "uid=\'#{options[:uid]}\'" if options[:uid]
    #      options[:onclick] = "onclick=\'#{options[:onclick]}\'" if options[:onclick]
    #      options[:class]   = "class=\'#{options[:class]}\'" if options[:class]
    #
    #      "<a #{options[:id]} #{options[:uid]} #{options[:href]} #{options[:onclick]} #{options[:class]}>#{options[:content]}</a>"
    #    end
    #
    #    def remove_room(user, room_name)
    #      "chat.removeRoom(#{user.id}, '#{room_name}')"
    #    end
    #
    #    def chat_scroll
    #      "chat.scroll"
    #    end
    #
    #    def chat_update_data(options)
    #      "chat.updateData(#{options.to_json})"
    #    end
    #
    #    def chat_user_id(user)
    #      "user_#{user.id}"
    #    end
    #
    #    def chat_group_room_name(type)
    #      "group_rooms_#{type}"
    #    end
    #
    #    def show_selected_avatar(user, message_id)
    #      "chat.showSelectedAvatar(#{get_user_info_options(user, current_user, message_id).to_json})"
    #    end
    #
    #    def get_user_info_options(user, owner, message_id = nil)
    #
    #      options = {}
    #      options[:id]            = user.id
    #      options[:name]          = ERB::Util.h(user.name)
    #      options[:level]         = user.a_level
    #      options[:online]        = user.is_chat_online?
    #      options[:gender]        = user.gender
    #      options[:message_id]    = message_id
    #      options[:avatar_url]    = user_image_url(user)
    #      options[:can_invite_main] = !user.has_room?(owner.chat_main_room_name)
    #      options[:can_invite_personal] = !user.has_room?("#{owner.id}_#{user.id}")
    #      options
    #    end
    #
    #    def chat_message_tag(user, message_id, message)
    #      options_info = {}
    #      options_info[:onclick] = "javascript: navigate(\"#{chat_path(:action => :user_info, :id => user.id, :message_id => message_id)}\")"
    #      options_info[:content] = "<img alt=\'.\' src=\'/images/design/info_alb.png\'/>"
    #
    #      options_user = {}
    #      options_user[:uid]     = "#{user.id}"
    #      options_user[:class]   = "active_always"
    #      options_user[:onclick] = "chat.sayTo(this)"
    #      options_user[:content] = user.name
    #
    #      tag = "<li>"
    #      tag << chat_link_to(options_info)
    #      tag << chat_link_to(options_user)
    #      tag << ": <span id='cm_#{message_id}'>#{message}</span></li>"
    #    end
    #
    #    def chat_user_tag(user, message_id = nil)
    #      online_url = user.is_chat_online? ? "online_chat_pointer.png" : "offline_chat_pointer.png"
    #
    #      options_a = {}
    #      options_a[:id]      = "link_#{chat_user_id(user)}"
    #      options_a[:onclick] = "javascript: navigate(\"#{chat_path(:action => :user_info, :id => user.id, :message_id => message_id)}\")"
    #      options_a[:class]   = "chat_user_info active_always"
    #      options_a[:content] = "<img id=\'small_user_ava_#{user.id}\' src=\'#{user_image_url(user, false)}\' height=\'109\'/>"
    #
    #      tag =  "<ul id='#{chat_user_id(user)}' class='chat_user_info'>"
    #      tag << "<li>#{chat_link_to(options_a)}</li>"
    #      tag << "<li class='chat_user_info_name'><img src='/images/design/#{online_url}'/>#{user_name(user, {:short_name => true})}</li></ul>"
    #      tag
    #    end
    #
    #    def smiles_replace(text)
    #      GameProperties::CHAT_SMILEYS.each do |smiley, smiley_name|
    #        text.gsub!(smiley, "<img src=\'/images/smiles/#{smiley_name}.gif\' alt=\'#{smiley}\' title=\'#{smiley}\'/>")
    #      end
    #      text
    #    end
    #

    #
    #    def chat_add_message(user, message_id, message, room_name)
    #      content = ::ActiveSupport::JSON.encode(chat_message_tag(user, message_id, smiles_replace(message)))
    #      "chat.addMessage(#{user.id}, #{content}, '#{room_name}');"
    #    end
    #
    #    def chat_add_room(user, room_name, title, is_main = false, selected = false)
    #      li = chat_room_li(room_name, title, is_main)
    #      group_room_name = is_main ? chat_group_room_name(Chat::GROUP_ROOM_MAIN) : chat_group_room_name(Chat::GROUP_PERSONAL)
    #      "chat.addRoom(#{user.id}, '#{room_name}', #{::ActiveSupport::JSON.encode(li)}, '#{group_room_name}', #{selected}); "
    #    end
    #
    #    def chat_room_li(room_name, title, is_main = false)
    #      options_room = {}
    #      options_room[:content] = title
    #      options_room[:onclick] = "javascript: chat.changeRoom(\"#{room_name}\")"
    #
    #      options_leave = {}
    #      options_leave[:content] = "<img widht='11' src='/images/design/cross_chat_button.gif'>"
    #      options_leave[:onclick] = is_main ? "chat.leaveMainRoom(\"#{room_name}\")" : "chat.leavePersonalRoom(\"#{room_name}\")"
    #
    #      li = "<li id=\'#{room_name}\'>#{chat_link_to(options_room)}<span class='right'><span class=\'chat_new_message\'></span><span class=\'delete_chat\'>#{chat_link_to(options_leave)}</span></span></li>"
    #      return li
    #    end
    #
    #    def chat_update_user(user, relative)
    #      "chat.updateUser(#{user.id}, '#{chat_user_id(relative)}', #{::ActiveSupport::JSON.encode(chat_user_tag(relative))})"
    #    end
    #
    #    def chat_rooms_tag(user, name)
    #
    #      rooms =  "<ul id ='#{chat_group_room_name(name)}'>"
    #      if name == Chat::GROUP_ROOM_PUBLIC
    #        user.chat_default_rooms.each do |r|
    #          o = {:content => r[:title], :onclick => "javascript: chat.changeRoom(\"#{r[:key]}\")"}
    #          rooms << "<li id='#{r[:key]}'>#{chat_link_to(o)}<span class='right'><span class='chat_new_message'></span></span></li>"
    #        end
    #      else
    #        user.e_get_chat_rooms.each do |room|
    #          if room[:kind] == name
    #            rooms << chat_room_li(room[:key], room[:title], room[:kind] == Chat::GROUP_ROOM_MAIN)
    #          end
    #        end
    #      end
    #      rooms << "</ul>"
    #      return rooms
    #    end

  end
end

module UserExt
  module Chat

    def chat_default_rooms
      rooms = [{:key => GameProperties::CHAT_PUBLIC_NAME, :title => t(:room_public)}]
      rooms << {:key => chat_main_room_name, :title => t(:room_main)}
      rooms << {:key => chat_clan_room_name, :title => t(:room_clan)} if self.clan
      rooms
    end

    def chat_clan_room_name
      "room_clan_#{self.clan.id}"
    end

    def chat_main_room_name
      "room_main_#{self.id}"
    end

    def has_room?(room_key)
      !get_room_by_name(room_key).nil?
    end

    def get_room_by_name(room_key)
      self.e_get_chat_rooms.each do |room|
        return room if room[:key] == room_key
      end
      nil
    end

    def ban!(time, options = {})
      BanHistory.ban!(self, time, options)
    end

    def active_ban
      BanHistory.active_ban(self)
    end

    def last_ban
      BanHistory.last_ban(self)
    end

    def t(key)
       I18n.t(key, {:scope => [:activerecord, :attributes, :chat]})
    end

  end

end

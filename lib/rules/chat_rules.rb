class ChatRules < AbstractRules

  def self.can_send_message(user, room, to_user = nil)
    r = Rule.new

    if !user.confirmed_email
      r.message = tg(:account_not_activated)
      return r
    end

    if user.a_level < GameProperties::CHAT_MIN_LEVEL
      r.message = t(:chat_required_level, :level => GameProperties::CHAT_MIN_LEVEL)
      return r
    end
    ban = user.active_ban
    if !user.active_messaging && !ban.nil?
      r.message = t(:chat_blocked, :reason => ban.public_reason, :user_name => user.name)
      return r
    end

    unless to_user.nil?
      ban = to_user.active_ban
      if ban && !to_user.active_messaging
        r.message = ban.ban_end_date.nil? ? t(:user_blocked_permanent, :name => to_user.name) : t(:user_blocked, :name => to_user.name, :time => d(ban.ban_end_date))
        return r
      end
    end


    return can_connect(user)
  end

  def self.can_connect(user)
    r = Rule.new

    if user.nil?
      r.message = t :user_not_found
      return r
    end

    ban = user.active_ban
    if !user.active_messaging && !ban.nil?
      r.message = t(:chat_blocked, :user_name => user.name, :reason => ban.public_reason)
      return r
    end

    if user.a_level < GameProperties::CHAT_MIN_LEVEL
      r.message = tg(:required_level, :level => GameProperties::CHAT_MIN_LEVEL)
      return r
    end

    r
  end

  def self.can_join_to_main(user)
    r = Rule.new

    if user.nil?
      r.message = t(:chat_user_not_found)
      return r
    end
    
    return can_connect(user)
  end

  def self.can_create_private(owner, relative)
    r = Rule.new

    #    if !owner.can_create_private_with?(user)
    #      r.message = t(:private_room_exists)
    #      return r
    #    end
    return can_connect(relative)
  end

  def self.can_block_user(moderator, user, time, reason)
    r = Rule.new
    if !moderator.is_moderator
      r.message = t(:you_are_not_moderator)
      return r
    end
    
    if user.is_moderator
      r.message = t(:you_cant_block_moderator)
      return r
    end

    if time == 0 || time > GameProperties::CHAT_BAN_TIMES_MAX
      r.message = t(:choise_a_time)
      return r
    end

    if reason.blank?
      r.message = t(:chat_ban_reason)
      return r
    end
    r
  end

  def self.can_send_report(reporter, user)
    r = Rule.new

    last_report_time = reporter.e_get_chat_report(user)
    if last_report_time && last_report_time > GameProperties::CHAT_REPORT_RESTRICTION_TIME.ago
      r.message = t(:report_already_exists)
      return r
    end
    return can_send_message(reporter, nil)
  end

end

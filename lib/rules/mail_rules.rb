class MailRules < AbstractRules

  def self.can_send_message(user, recipient, title, message, name)
    r = Rule.new

    if recipient.nil?
      if name.blank?
        r.message = t(:please_choice_yours_friend)
      else
        r.message = t(:please_choice_yours_friend_name, :name => name)
      end
      return r
    end

    if title.blank?
      r.message = t(:title_cant_be_empty)
      return r
    end

    if message.blank?
      r.message = t(:message_cant_be_empty)
      return r
    end

    if !user.confirmed_email
      r.message = tg(:account_not_activated)
      return r
    end

    if user == recipient
      r.message = t(:you_cant_send_yourself)
      return r
    end

    if user.a_level < GameProperties::MIN_LEVEL_TO_EDIT_MESSAGES
      r.message = tg :required_min_level, :min => GameProperties::MIN_LEVEL_TO_EDIT_MESSAGES
      return r
    end

    if recipient.is_ignore_list?(user)
      r.message = t(:you_are_blocked_with_user)
      return r
    end
    
    r
    
  end

  def self.can_send_clan_message(user, message = true)
    r = Rule.new

    if user.clan.nil?
      r.message = t(:you_not_have_clan)
      return r
    end

    if message.blank?
      r.message = t(:clan_message_cant_empty)
      return r
    end
    r
  end

end

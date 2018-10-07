class Message < ActiveRecord::Base

  # include base mode behaviour
  include BaseModel

  belongs_to :user
  
  ALL_USERS = 0

  MESSAGE_FROM = 1
  MESSAGE_TO = 2
  USER_MESSAGES = [MESSAGE_FROM, MESSAGE_TO]
  
  TASK_DONE = 5
  PET_EVENT = 6
  PRESENT_EVENT = 7
  PRESENT_POTION_EVENT = 71
  MEDITATION_EVENT = 8
  WELCOM_GURU = 9

  NEW_LEVEL = 14
  STORE_MAX_MANA = 15
  ACHIVEMENT = 16

  MESSAGE_FROM_ADMIN = 61
  MESSAGES_BANNED = 62
  MESSAGES_UNBANNED = 63
  
  #  QUEST_EVENT = 20
  DRAGON_EVENT = 25

  FIGHT_USER = 31
  FIGHT_OPPONENT = 32
  FIGHT_TRY = 33
  
  NEW_EVENT_EVENT = 40
  PET_EVENT_ACTIVATE = 45
  PET_EVENT_DEACTIVATE = 46
  SHOP_SELL_EVENT = 48

  ADYEN_PROCESSED = 50
  ADYEN_REFUSED = 51

  EVENTS              = [WELCOM_GURU, FIGHT_TRY, TASK_DONE, PET_EVENT, PRESENT_EVENT, PRESENT_POTION_EVENT, MEDITATION_EVENT, MESSAGE_FROM_ADMIN, ADYEN_PROCESSED, ADYEN_REFUSED, MESSAGES_BANNED, NEW_LEVEL, STORE_MAX_MANA, DRAGON_EVENT, ACHIVEMENT]
  ALL_UNREAD_MESSAGES = [MESSAGE_FROM, FIGHT_OPPONENT] + EVENTS

  #  SUPPORT_Q_NEW, SUPPORT_Q_RESOLVED, SUPPORT_A_PRIVATE, SUPPORT_Q_PUBLIC, SUPPORT_A_PUBLIC = 9, 10, 11, 12, 13

  #  MESSAGES = [MESSAGE_FROM, MESSAGE_TO, MESSAGE_FROM_ADMIN, MESSAGES_BANNED, MESSAGES_UNBANNED]
  #  SUPPORT_Q = [SUPPORT_Q_NEW, SUPPORT_Q_RESOLVED, SUPPORT_Q_PUBLIC]
  #  SUPPORT_A = [SUPPORT_A_PRIVATE, SUPPORT_A_PUBLIC]
  #  SUPPORT = SUPPORT_Q + SUPPORT_A
  #  EVENTS = [FIGHT_USER, FIGHT_OPPONENT, PATROL, FIGHT_TRY, FARM, QUEST_EVENT,
  #    DRAGON_EVENT, NEW_EVENT_EVENT, PET_EVENT_ACTIVATE, PET_EVENT_DEACTIVATE, SHOP_SELL_EVENT]

  # support categoris
  #  SUPPORT_CATEGORY_DISABLED_USER = "disabled"
  #  ALL_SUPPORT_CATEGORIES = GameProperties::SUPPORT_CATEGORIES + [SUPPORT_CATEGORY_DISABLED_USER]


  def self.send_message(from_user, to_user, title, message)

    Message.create! :user => from_user,
      :title => title,
      :kind => MESSAGE_TO,
      :detail => to_user.id,
      :message => message

    #    if !to_user.ignore_user?(from_user)
    Message.create! :user => to_user,
      :title => title,
      :kind => MESSAGE_FROM,
      :detail => from_user.id,
      :message => message
    #    end
  end

  def self.sent_messages(user_id, page = 1)
    user_messages_history(user_id, nil, page, MESSAGE_TO)
  end

  def self.incoming_messages(user_id, page = 1)
    user_messages_history(user_id, nil, page, MESSAGE_FROM)
  end

  def self.user_messages_history(user_id, author_id = nil, page = 1, kind = USER_MESSAGES)
    sql = <<-SQL
      SELECT m.*, u.id AS user2_id, u.name AS user2_name FROM messages AS m
      LEFT JOIN users as u ON (u.id = m.detail)
      WHERE m.user_id = ? 
    SQL

    if author_id.nil?
      sql   += " AND m.kind in (?) ORDER BY m.id DESC"
      params = [sql, user_id, kind]
    else
      sql   += "AND m.detail = ? AND m.kind in (?) ORDER BY m.id DESC"
      params = [sql, user_id, author_id, kind]
    end

    Message.paginate_by_sql(params, :page => page, :per_page => per_page)
  end

  def self.delete_all_from(user, relative)
    Message.delete_all ['user_id = ? and detail = ? and kind = ?', user.id, relative.id, MESSAGE_FROM]
  end

  def self.select_message(id, user_id)
    Message.find :first,
      :select => "messages.*, messages.detail as user2_id, u.name as user2_name",
      :joins => "LEFT JOIN users u on u.id = messages.detail ",
      :conditions => {:id => id, :user_id => user_id}
  end

  def self.send_ban_messaging(ban)
    #    #TODO
  end

  def self.user_notifications(user, page = 1, perpage = per_page)
    paginate :conditions => ["user_id = ? and kind in (?)", user.id, EVENTS], :order => "created_at DESC",
      :page => page, :per_page => perpage
  end

  def self.get_fights(user, page = 1, perpage = per_page)
    paginate :conditions => ["user_id = ? and kind in (?)", user.id, [FIGHT_USER, FIGHT_OPPONENT ]], :order => "created_at DESC",
      :page => page, :per_page => perpage
  end

  def self.create_fight_try(user, opponent)

    Message.create! :user => opponent,
      :title => t(:try_fight, :name => user.name),
      :kind => FIGHT_TRY,
      :detail => user.id,
      :message => t(:try_fight, :name => user.name)

  end

  def self.create_fight(fight_log)

    user_is_monster = fight_log.user_a.monster? || fight_log.user_a.dragon?
    opponent_is_monster = fight_log.opponent_a.monster? || fight_log.opponent_a.dragon?

    if fight_log.user_won

      options_u = {
        :id => fight_log.opponent.id,
        :name => user_name(fight_log.opponent, :short_name => true),
        :money => fight_log.winner_money_diff.abs
      }
      key_u = :you_strike_win

      options_o = {
        :id => fight_log.user.id,
        :name => user_name(fight_log.user, :short_name => true),
        :money => fight_log.loser_money_diff.abs
      }
      key_o = :you_striked_lose

      #      if fight_log.winner_staff2_diff > 0
      #        options_u[:staff2] = fight_log.winner_staff2_diff
      #        key_u = :you_strike_win_staff2
      #
      #        options_o[:staff2] = fight_log.winner_staff2_diff
      #        key_o = :you_striked_lose_staff2
      #      end
    else
      options_u = {
        :id => fight_log.opponent.id,
        :name => user_name(fight_log.opponent, :short_name => true),
        :money => fight_log.loser_money_diff.abs
      }
      key_u = :you_strike_lose

      options_o = {
        :id => fight_log.user.id,
        :name => user_name(fight_log.user, :short_name => true),
        :money => fight_log.winner_money_diff.abs
      }
      key_o = :you_striked_win

      #      if fight_log.winner_staff2_diff > 0
      #        options_u[:staff2] = fight_log.winner_staff2_diff
      #        key_u = :you_strike_lose_staff2
      #
      #        options_o[:staff2] = fight_log.winner_staff2_diff
      #        key_o = :you_striked_win_staff2
      #      end
    end

    if fight_log.pet_fight && (fight_log.loser_pet_killed || fight_log.winner_pet_killed)

      if (fight_log.loser_pet_killed && fight_log.user_won) ||
          (fight_log.winner_pet_killed && !fight_log.user_won)

        u_kill_pet_message = t(:you_kill_pet, :name => user_name(fight_log.opponent))
        o_kill_pet_message = t(:your_pet_killed)
      else
        u_kill_pet_message = t(:your_pet_killed)
        o_kill_pet_message = t(:you_kill_pet, :name => user_name(fight_log.user))
      end
    else
      u_kill_pet_message = ""
      o_kill_pet_message = ""
    end

    Message.create! :user => fight_log.user,
      :title => t(key_u, options_u) + u_kill_pet_message,
      :kind => FIGHT_USER,
      :extra => fight_log.user_won ? 'w' : 'l',
      :detail => fight_log.id if !user_is_monster

    Message.create! :user => fight_log.opponent,
      :title => t(key_o, options_o) + o_kill_pet_message,
      :kind => FIGHT_OPPONENT,
      :extra => fight_log.user_won ? 'l' : 'w',
      :detail => fight_log.id if !opponent_is_monster

  end



  def self.done_task(user, description)
    Message.create! :user => user,
      :title => t(:done_task),
      :kind => TASK_DONE,
      :detail => user.id,
      :message => description

  end

  #  def self.create_pet_event(user, activate, message_key = nil) # TODO ...
  #
  #    message_key ||= activate ? :pet_activate : :pet_deactivate
  #
  #    Message.create! :user => user,
  #      :title => t(:pet_title),
  #      :kind => PET_EVENT,
  #      :detail => user.id,
  #      :message => t(message_key)
  #
  #  end

  def self.create_sent_present(recipient, user, present, type)
    title = t("receive_#{type}_title")
    message = t("receive_#{type}_message", :user_name => user.name, :present_name => present.present_name)

    Message.create! :user => recipient,
      :title => title,
      :kind => PRESENT_EVENT,
      :detail => user.id,
      :message => message

  end

  def self.create_present_potion_usage(user, curse = nil)
    Message.create! :user => user,
      :title => curse ? t(:present_potion_used, :name => curse.title) : t(:present_potion_all_used),
      :kind => PRESENT_POTION_EVENT
  end

  def self.create_meditation(user, options = {})

    if options[:meditation_curse]
      message = t(:meditation_curse)
      message += t(:meditation_curse_experience, :experience => user.meditation_experience) if user.meditation_experience
    else
      if options[:meditation_nirvana]
        message = t(:meditation_nirvana, :money => user.meditation_money)
      else
        message = t(:meditation_content, :money => user.meditation_money)
      end
      message += t(:meditation_experience, :experience => user.meditation_experience) if user.meditation_experience
    end
    

    Message.create! :user => user,
      :title => "",
      :kind => MEDITATION_EVENT,
      :detail => user.id,
      :message => message
  end

  def self.send_admin_message(to_user, message, title = nil)
    Message.create! :user => to_user,
      :title => title || t(:message_from_admin),
      :kind => MESSAGE_FROM_ADMIN,
      :message => message
  end

  def self.send_bonus_message(user, money, staff, reason, title = nil)
    if money > 0
      message = t(:bonus_reason_message_money, :money => tp(money), :reason => reason)
    else
      message = t(:bonus_reason_message_staff, :staff => tps(staff), :reason => reason)
    end

    self.send_admin_message user, message, title
  end

  def self.send_reference_bonus_level(user, referral, bonus = 0)
    if bonus && bonus > 0
      title = t(:reference_riched_level_bonus_title, :staff => tps(bonus))
      message = t(:reference_riched_level_bonus, :level => referral.a_level, :name => referral.name, :staff => tps(bonus))

      Message.send_admin_message user, message, title
    end    
  end

  def self.send_buy_gold_processed(user, staff)
    Message.create! :user => user,
      :title => t(:payment_processed_tile),
      :kind => ADYEN_PROCESSED,
      :message => t(:payment_processed, :amount => staff)
  end

  def self.send_buy_gold_refused(user, staff)
    Message.create! :user => user,
      :title => t(:payment_refused_title),
      :kind => ADYEN_REFUSED,
      :message => t(:payment_refused, :amount => staff)
  end

  def self.mark_messages_as_read!(user)
    self.mark_as_read!(user, :e_messages_read_at)
  end

  def self.mark_incoming_as_read!(user)
    self.mark_as_read!(user, :e_incoming_read_at)
  end

  def self.mark_events_as_read!(user)
    self.mark_as_read!(user, :e_events_read_at)
  end

  def self.mark_fights_as_read!(user)
    self.mark_as_read!(user, :e_fights_read_at)
  end

  def self.mark_as_read!(user, read_at)
    eval("user.#{read_at} = Time.now")
    user.save!
  end

  def self.has_unread_messages?(user)
    return false if user.e_messages_read_at.nil?
    
    m = last :conditions => ['user_id in (?, ?) and kind in (?)', user.id, ALL_USERS, ALL_UNREAD_MESSAGES]
    m && user.e_messages_read_at && m.created_at > user.e_messages_read_at
  end

  def self.unread_incoming_count(user)
    self.unread_count(user, MESSAGE_FROM, user.e_incoming_read_at)
  end

  def self.unread_events_count(user)
    self.unread_count(user, EVENTS, user.e_events_read_at)
  end

  def self.unread_fight_count(user)
    self.unread_count(user, FIGHT_OPPONENT, user.e_fights_read_at)
  end

  def self.unread_count(user, kinds, read_at)
    return 0 if read_at.nil?
    count :conditions => ['user_id = ? and kind in (?) and created_at > ?', user.id, kinds, read_at]
  end

  def self.new_level(user, level)
    message = t(:you_reached_new_level, :level => level)

    Message.create! :user => user,
      :title => message,
      :kind => NEW_LEVEL,
      :message => message
  end

  def self.store_max_mana(user)
    Message.create! :user => user,
      :title => t(:you_stored_max_mana_title),
      :kind => STORE_MAX_MANA,
      :message => t(:you_stored_max_mana)
  end

  def self.send_guru_message(user)
    Message.create! :user => user,
      :title => "",
      :kind => WELCOM_GURU,
      :message => t(:message_from_guru)
  end

  #  def self.get_category_label(category)
  #    Message.tf(Message, "category_#{category}".to_sym)
  #  end
  #
  #  def category_label
  #    SUPPORT.include?(kind) && extra ? Message.get_category_label(extra) : ''
  #  end
  #

  #  def self.has_unread?(user)
  #    ClanMessage.has_unread_messages?(user) ||
  #    CommunityMessage.has_unread_messages?(user) ||
  #    has_unread_messages?(user) ||
  #    has_unread_support?(user) ||
  #    NewsMessage.has_unread_news?(user)
  #  end
  #
  #  def self.has_unread_support?(user)
  #    return true if !user.messages_read_at
  #    m = find_by_user_id_and_kind user.id, SUPPORT, :order => "updated_at desc"
  #    m && m.updated_at > user.messages_read_at
  #  end
  #
  #  

  #  def self.user_support(user, page = 1)
  #    Message.paginate_by_user_id_and_kind user.id, Message::SUPPORT,
  #      :page => page,
  #      :order => 'created_at desc'
  #  end
  #
  #  def self.faq(page = 1)
  #    Message.paginate_by_kind [Message::SUPPORT_Q_PUBLIC, Message::SUPPORT_A_PUBLIC],
  #      :page => page,
  #      :order => 'created_at desc'
  #  end

  #
  #  def self.send_ban_messaging(ban)
  #    banned_by = ban.banned_by ? h(ban.banned_by.name) : t(:messaging_banned_by_admin)
  #    Message.create! :user => ban.user,
  #      :title => ban.ban ? t(:messaging_banned, :date => d(ban.ban_end_date)) : t(:messaging_unbanned),
  #      :kind => ban.ban ? MESSAGES_BANNED : MESSAGES_UNBANNED,
  #      :message => ban.ban ? t(:messaging_banned_reason, :reason => h(ban.public_reason), :by => banned_by) : nil
  #  end

  def self.create_fight_dragon(fight_log)
    Message.create! :user => fight_log.user,
      :title => t(fight_log.user_won ? :you_strike_dragon_win : :you_strike_dragon_lose),
      :kind => FIGHT_USER,
      :extra => fight_log.user_won ? 'w' : 'l',
      :detail => fight_log.id
  end

  #  def self.create_quest_event(user, key, options)
  #    o = {}
  #
  #    if options[:user]
  #      o[:user_id] = options[:user].id
  #      o[:user_name] = options[:user].name
  #    end
  #
  #    if options[:quest]
  #      o[:quest_id] = options[:quest].id
  #      o[:quest_name] = options[:quest].name
  #    end
  #
  #    Message.create! :user => user,
  #      :title => t(key, o),
  #      :kind => QUEST_EVENT
  #  end

  def self.create_dragon_event(user, key, options)
    Message.create! :user => user,
      :title => t(key, options),
      :kind => DRAGON_EVENT
  end

  def self.create_fight_kill_pet_curse(user)
    Message.create! :user => user,
      :title => t(:fight_kill_pet_curse),
      :kind => PET_EVENT
  end

  def self.create_achivement_event(user, level, name, bonus)
    Message.create! :user => user,
      :title => t(:achivement_new_level, :name => name, :level => level, :bonus => bonus),
      :kind => ACHIVEMENT
  end


end

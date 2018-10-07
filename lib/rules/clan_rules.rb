class ClanRules < AbstractRules

  def self.can_create_clan(user)
    r = Rule.new

    if !user.confirmed_email
      r.message = tg(:account_not_activated)
      return r
    end

    if user.clan
      r.message = tg(:strange_situation)
      return r
    end

    if user.a_level < GameProperties::CLAN_MIN_CREATE_LEVEL
      r.message = t(:clan_create_min_level, :min => GameProperties::CLAN_MIN_CREATE_LEVEL)
      return r
    end

    if user.e_last_clan_leave_time && user.e_last_clan_leave_time > GameProperties::CLAN_TIME_BETWEEN_CLAN_JOINS_ON_LEAVE.ago
      r.message = t(:clan_join_restriction,
        :remain => (user.e_last_clan_leave_time - GameProperties::CLAN_TIME_BETWEEN_CLAN_JOINS_ON_LEAVE.ago).seconds_to_full_time
      )
      return r
    end

    r
  end

  def self.can_process_create_clan(user)
    can_create_clan(user)
  end

  def self.can_edit_clan(user)
    r = Rule.new

    if !is_clan_owner(user)
      r.message = tg(:strange_situation)
      return r
    end

    r
  end

  def self.can_process_edit_clan(user)
    r = can_edit_clan(user)
    return r if !r.allow?

    clan = user.clan
    if clan.a_money < GameProperties::CLAN_CHANGE_PRICE
      r.message = t(:not_enought_money_to_edit, {:price => tp(GameProperties::CLAN_CHANGE_PRICE)})
      return r
    end

    if clan.on_war?
      r.message = t(:edit_on_war)
      return r
    end

    r
  end

  def self.can_join(user, clan)
    r = Rule.new

    if !user.confirmed_email
      r.message = tg(:account_not_activated)
      return r
    end
    
    if !user || !clan
      r.message = tg(:strange_situation)
      return r
    end

    if user.a_level < GameProperties::CLAN_MIN_JOIN_LEVEL
      r.message = t(:clan_join_min_level, :min => GameProperties::CLAN_MIN_JOIN_LEVEL)
      return r
    end

    if user.clan == clan
      r.message = t(:already_in_this_clan, :name => user.name)
      return r
    end

    if user.clan
      r.message = t(:already_has_clan_on_join, :name => user.name);
      return r
    end

    if clan.free_places == 0
      r.message = t(:there_is_no_place_in_clan)
      return r
    end

    if user.e_last_clan_leave_time && user.e_last_clan_leave_time > GameProperties::CLAN_TIME_BETWEEN_CLAN_JOINS_ON_LEAVE.ago
      r.message = t(:clan_join_restriction,
        :remain => (user.e_last_clan_leave_time - GameProperties::CLAN_TIME_BETWEEN_CLAN_JOINS_ON_LEAVE.ago).seconds_to_full_time
      )
      return r
    end

    if clan.on_war?
      r.message = t(:join_requests_on_war)
      return r
    end

    r
  end

  def self.can_send_join_request(user, clan, message)
    r = can_join(user, clan)
    return r if !r.allow?

    if ClanMessage.requested_join?(clan, user)
      r.message = t(:already_requested_join)
      return r
    end

    if message.blank?
      r.message = t(:join_message_is_blank)
      return r
    end

    r
  end

  def self.can_process_join(user, clan)
    r = can_join(user, clan)
    return r if !r.allow?
    
    if clan.s_month_joins >= GameProperties::CLAN_MAX_JOINS_PER_MONTH
      r.message = t(:max_join_requests,
        :max => GameProperties::CLAN_MAX_JOINS_PER_MONTH,
        :remain => (Time.now.end_of_month - Time.now).seconds_to_full_time
      )
      return r
    end

    r
  end

  def self.can_leave_clan(user)
    r = Rule.new

    if (user.is_clan_owner? && user.is_clan_creator?) || user.clan.nil?
      r.message = tg(:strange_situation)
      return r
    end

    if user.clan.on_war?
      r.message = t(:leave_clan_on_war)
      return r
    end

    r
  end

  def self.can_kick_from_clan(owner, user)
    r = Rule.new

    if owner == user ||
        !owner.is_clan_owner? ||
        user.is_clan_creator? ||
        user.clan != owner.clan ||
        user.clan.on_war?
      r.message = tg(:strange_situation)
      return r
    end

    if user.clan.on_war?
      r.message = t(:kick_on_war)
      return r
    end

    r
  end

  def self.can_donate(price)
    r = Rule.new

    user = price.user
    if user.clan.nil?
      r.message = tg(:strange_situation)
      return r
    end

    if user.clan.on_war? && price.price > 0
      r.message = tg(:strange_situation)
      return r
    end

    if price.price < 0 || price.price_staff2 < 0
      r.message = t(:donate_minus)
      return r
    end

    if price.price == 0 && price.price_staff2 == 0
      r.message = t(:donate_zero)
      return r
    end

    if !price.is_money? && price.price > 0
      r.message = t(:donate_not_enought_money)
      return r
    end

    if !price.is_staff2? && price.price_staff2 > 0
      r.message = t(:donate_not_enought_staff2)
      return r
    end

    r
  end

  def self.can_get_ownership(user, clan)
    r = Rule.new

    if !is_clan_creator(user) || !clan || user.clan != clan
      r.message = tg(:strange_situation)
      return r
    end

    r
  end

  def self.can_change_owner(user, clan, new_owner)
    r = Rule.new

    if !is_clan_owner(user) || !clan || user.clan != clan || new_owner.clan != clan
      r.message = tg(:strange_situation)
      return r
    end

    r
  end

  def self.can_improve(user, clan, item)
    r = Rule.new

    if !item || !clan || clan.on_war?
      r.message = tg(:strange_situation)
      return r
    end

    if clan.owner != user
      r.message = t(:only_owner_can_extend)
      return r
    end

    item.can_extend?(clan)
  end

  def self.can_kill_clan(user, clan) # TODO
    r = Rule.new

    if !is_clan_creator(user)
      r.message = tg(:strange_situation)
      return r
    end

    if clan.on_war?
      r.message = t(:kill_on_war)
      return r
    end

    r
  end

  def self.can_start_war(clan, opponent_clan)
    r = Rule.new

    if !clan.has_altar?
      r.message = t(:war_no_altar)
      return r
    end

    if clan.on_war?
      r.message = t(:war_clan_is_on_war)
      return r
    end

    if opponent_clan.on_war?
      r.message = t(:war_opponent_clan_is_on_war, :name => opponent_clan.name)
      return r
    end

    last_war = clan.get_last_war
    if last_war && last_war.finished? && last_war.finished_at > GameProperties::CLAN_REST_TIME_AFTER_WAR.ago
      r.message = t(:war_rest_time_restriction,
          :remain => (last_war.finished_at - GameProperties::CLAN_REST_TIME_AFTER_WAR.ago).seconds_to_full_time
        )
      return r
    end

    last_war = opponent_clan.get_last_war
    if last_war && last_war.finished? && last_war.finished_at > GameProperties::CLAN_REST_TIME_AFTER_WAR.ago
      r.message = t(:war_rest_time_opponent_restriction,
          :name => opponent_clan.name,
          :remain => (last_war.finished_at - GameProperties::CLAN_REST_TIME_AFTER_WAR.ago).seconds_to_full_time
        )
      return r
    end

    altar_started_wars = clan.get_current_month_altar_started_wars_count
    if altar_started_wars >= clan.amount_of_wars_per_month
      r.message = t(:war_amount_restriction,
        :count => clan.amount_of_wars_per_month
      )
      return r
    end

    if clan.user_count < GameProperties::CLAN_MIN_USERS_TO_START_WAR
      r.message = t(:war_start_places_restriction, :min => GameProperties::CLAN_MIN_USERS_TO_START_WAR)
      return r
    end

#    if opponent_clan.user_count < GameProperties::OPPONENT_CLAN_MIN_USERS_TO_START_WAR
#      r.message = t(:war_start_places_restriction_opponent, :min => GameProperties::OPPONENT_CLAN_MIN_USERS_TO_START_WAR)
#      return r
#    end

    if opponent_clan.get_current_month_started_wars_by_other_clans_count >= GameProperties::CLAN_WAR_MAX_STARTED_WARS_BY_OPPONENTS
      r.message = t(:war_start_started_wars_by_opponent_restriction,
        :max => GameProperties::CLAN_WAR_MAX_STARTED_WARS_BY_OPPONENTS,
        :remain => (Time.now.next_month.beginning_of_month - Time.now).seconds_to_full_time
      )
      return r
    end

    last_war = clan.get_last_started_war_with_clan(opponent_clan)
    if last_war && last_war.started_at > GameProperties::CLAN_WARS_WITH_THE_SAME_CLAN_PERIOD.ago
      r.message = t :war_start_with_the_same_clan_time_restrict,
        :remain => (last_war.started_at - GameProperties::CLAN_WARS_WITH_THE_SAME_CLAN_PERIOD.ago).seconds_to_full_time
      return r
    end

    if clan.get_users_protection * 2 < opponent_clan.get_users_protection
      r.message = t(:war_start_war_protection_restriction, :name => opponent_clan.name)
      return r
    end

    r
  end

  def self.can_see_war_history(clan, war)
    r = Rule.new
    if clan.nil?
      r.message = tg(:strange_situation)
      return r
    end

    if war && (war.clan != clan && war.opponent_clan != clan)
      r.message = tg(:strange_situation)
      return r
    end
    r
  end

  private

  def self.is_clan_owner(user)
    user.is_clan_owner(user.clan)
  end

  def self.is_clan_creator(user)
    user.is_clan_creator(user.clan)
  end

end

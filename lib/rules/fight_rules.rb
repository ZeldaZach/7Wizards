class FightRules < AbstractRules

  def self.can_fight_find(user)
    r = can_fight(user)
    return r if !r.allow?

    #    if user.in_running_quest?
    #      r.message = t(:in_quest)
    #      return r
    #    end

    if user.a_money < user.fight_price
      r.message = t :not_enought_money_to_fight_find, :min => tp(user.fight_price)
      return r
    end

    r
  end

  def self.can_see_fight_details(user, fight_log)
    r = Rule.new

    if fight_log.nil? || (fight_log.user != user && fight_log.opponent != user)
      r.message = tg(:strange_situation)
      return r
    end

    r
  end

  def self.can_fight_with_opponent(user, opponent, refresh = false)

    r = can_fight(user)
    return r if !r.allow?  

    if opponent.nil? || opponent.id == user.id
      r.message = tg(:strange_situation)
      return r
    end
    
    if refresh && !opponent.virtual? && !opponent.monster?
      r.message = t(:something_changed)
      return r
    end

    if opponent.on_holiday? 
      r.message = t(:opponent_on_holiday, { :user => opponent.name })
      return r
    end

    if user.e_fights_count.nil? || user.e_fights_count <= 0
      remain = user.remaining_fight_regenerate_time
      if remain > 0
        r.message = t( :fight_count_restriction, { :remain => remain.seconds_to_time } )
        return r
      end
    end

    if AllGameItems::VOODOO.is_active?(opponent) && !user.on_war_with_user?(opponent)
      r.message = t(:fight_opponent_use_voodoo)
      return r
    end

    #    if opponent.monster?
    #      return r
    #    end

    # all rules below will be checked for non monster opponents

    #    if fight_find_time > 0 && opponent.updated_at.to_i > fight_find_time
    #      r.message = t(:opponent_was_updated)
    #      return r
    #    end

    #    if user.in_running_quest?
    #      r.message = t(:in_quest)
    #      return r
    #    end

    if user.on_war_with_user?(opponent)
      if UserItems::ShopGiftWarHidden.hidden_on_war?(opponent)
        r.message = t(:hidden_on_war_because_of_gift, { :user => opponent.name })
        return r
      end

      return r
    end

    # all rules below will be checked for non war user

    #    if user.in_community_with?(opponent)
    #      r.message = t( :fight_community_restriction )
    #      return r
    #    end

    #    if opponent.is_house_hidden?
    #      r.message = t(:opponent_is_hidden, { :user => opponent.name })
    #      return r
    #    end

#    if (user.a_level - opponent.a_level) > GameProperties::FIGHT_MIN_LEVEL_DIFF_TO_FIGHT && !user.on_war_with_user?(opponent)
#      r.message = t(:min_level_diff_restriction)
#      return r
#    end
    
#    if user.a_reputation < GameProperties::FIGHT_MIN_REPUTATION_TO_FIGHT_LOSERS &&
#        user.a_level - opponent.a_level > GameProperties::FIGHT_REPUTATION_LEVEL_DIFF &&
#        !user.on_war_with_user?(opponent)
#
#      r.message = t(:reputation_restriction, :min => GameProperties::FIGHT_MIN_REPUTATION_TO_FIGHT_LOSERS)
#      return r
#    end

    #    t = user.e_get_last_user_attack_time(opponent.id)
    #    if (t && t > GameProperties::FIGHT_WITH_OPPONENT_AND_YOU_PERIOD.ago)
    #      r.message = t(:opponent_restriction_to_fight_with_you,
    #        {
    #          :remain => (t - GameProperties::FIGHT_WITH_OPPONENT_AND_YOU_PERIOD.ago).seconds_to_time,
    #          :limit => GameProperties::FIGHT_WITH_OPPONENT_AND_YOU_PERIOD.seconds_to_time
    #        }
    #      )
    #      return r
    #    end

    if !user.on_union_war?(opponent)

      t = Time.now.day_start

      count = user.e_get_user_attacks_count(opponent.id, t)
      if count >= GameProperties::FIGHT_MAX_FIGHTS_WITH_OPPONENT_PER_DAY && !user.on_war_with_user?(opponent)
        r.message = t(:max_fights_with_opponent_reached,
          {
            :max => GameProperties::FIGHT_MAX_FIGHTS_WITH_OPPONENT_PER_DAY
          }
        )
        return r
      end

      count = opponent.e_attacks_count(t) 
      if count >= GameProperties::FIGHT_MAX_USER_FIGHTS_PER_DAY && !user.on_war_with_user?(opponent)
        r.message = t(:max_user_fights_reached,
          {
            :max => GameProperties::FIGHT_MAX_USER_FIGHTS_PER_DAY
          }
        )
        return r
      end

      if is_max_fight(user)
        r.message = t(:max_user_fights_pet_day_reached,
          {
            :max => GameProperties::FIGHT_MAX_FIGHTS_COUNT_PER_DAY
          }
        )
        return r
      end
      
    end
    
    r
  end

  def self.can_fight_with_dragon(user, dragon)
    r = can_fight(user)
    return r if !r.allow?

    if !dragon
      r.message = tg(:strange_situation)
      return r
    end

    if user.a_level < GameProperties::DRAGON_MIN_USER_LEVEL
      r.message = t(:dragon_min_user_level, :min => GameProperties::DRAGON_MIN_USER_LEVEL)
      return r
    end

    if dragon.killed? || dragon.dying?
      r.message = t(:dragon_dead)
      return r
    end

    if dragon.left? || dragon.leave_at < Time.now
      r.message = t(:dragon_left)
      return r
    end

    r
  end

  def self.is_max_fight(user)
    t = Time.now.day_start
    count = user.e_get_user_fights_count(t)
    count >= GameProperties::FIGHT_MAX_FIGHTS_COUNT_PER_DAY
  end

  private

  def self.can_fight(user)
    r = Rule.new

    if user.meditating?
      r.message = t(:meditating)
      return r
    end

    if (user.a_health < GameProperties::FIGHT_MINIMAL_HEALTH)
      r.message = t(:not_enought_health_to_fight_user, {:min => GameProperties::FIGHT_MINIMAL_HEALTH})
      return r
    end

    if (user.e_fights_count && user.e_fights_count <= 0)
      r.message = t(:fights_limit, :count => user.max_fights_count, 
        :time => user.regeneration_time_per_fight.seconds_to_time, :remain => user.remaining_fight_regenerate_time.seconds_to_time)
      return r
    end

    r
  end

  def self.can_see_fight_log(user, log)
    r = Rule.new
    if log.nil? || (user != log.user && user != log.opponent)
      r.message = t :cant_see_log
      return r
    end
    r
  end

end

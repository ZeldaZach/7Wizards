class GameEnduranceItem < AbstractGameTimeItem

  KEY = 'endurance'

  def description(user = nil)
    t description_translate_key,
        :times => GameProperties::FIGHT_ADVANCED_REGENERATION_TIME / 1.minute,
        :amount => GameProperties::FIGHT_ADVANCED_MAX_FIGHTS_COUNT
  end

  class << self

    def get_max_fights_count(user)
      endurance_active = AllGameItems::ENDURANCE.is_active?(user)
      max_count = endurance_active ?
        GameProperties::FIGHT_ADVANCED_MAX_FIGHTS_COUNT :
        GameProperties::FIGHT_MAX_FIGHTS_COUNT
      max_count
    end

    # will return time in seconds when new fight will be added
    def get_remaining_fight_regenerate_time(user)
      r = 0
      if user.e_fight_count_regenerated_at
        regeneration_time = get_fight_regeneration_time(user)
        if user.e_fight_count_regenerated_at > regeneration_time.seconds.ago
          r = user.e_fight_count_regenerated_at - regeneration_time.seconds.ago
        end
      end
      r
    end

    def get_fight_regeneration_time(user)
      endurance_active = AllGameItems::ENDURANCE.is_active?(user)
      return endurance_active ?  GameProperties::FIGHT_ADVANCED_REGENERATION_TIME : GameProperties::FIGHT_REGENERATION_TIME
    end

    def adjust?(user)
      if get_remaining_fight_regenerate_time(user) == 0 && user.e_fights_count && user.e_fights_count < user.max_fights_count

        if user.e_fight_count_regenerated_at
          time_passed = Time.now - user.e_fight_count_regenerated_at
          endurance_active = AllGameItems::ENDURANCE.is_active?(user)
          regeneration_time = endurance_active ?
            GameProperties::FIGHT_ADVANCED_REGENERATION_TIME :
            GameProperties::FIGHT_REGENERATION_TIME

          time_periods_passed = (time_passed / regeneration_time).to_i

          user.e_fights_count += time_periods_passed
          user.e_fights_count = [user.e_fights_count, user.max_fights_count].min

          if user.e_fights_count < user.max_fights_count
            user.e_fight_count_regenerated_at += time_periods_passed * regeneration_time
          else
            user.e_fight_count_regenerated_at = nil
          end
        else
          user.e_fight_count_regenerated_at = Time.now
        end

        return true
      elsif user.e_fights_count.nil?
        user.e_fights_count = GameProperties::USER_INITIAL_FIGHTS
        return true
      end
      false
    end

  end
end

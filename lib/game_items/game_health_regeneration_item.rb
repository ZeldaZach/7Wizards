class GameHealthRegenerationItem
  class << self
    
    def reset(user)
      user.e_health_regenerated_at = Time.now
      user.e_pet_health_regenerated_at = Time.now
    end

    def adjust?(user)
      r = adjust_user?(user)
      adjust_pet?(user) || r
    end

    private

    def adjust_user?(user)
      if !user.e_health_regenerated_at
        user.e_health_regenerated_at = Time.now
        return true
      else
        t = Time.now
        mins = (t - user.e_health_regenerated_at).seconds_to_minutes
        if mins >= 10
          per_hour = user.health_hour_regeneration
          regenec = UserItems::AmuletRegenec.get_percent(user)
          per_hour = per_hour.to_f * ( 1 + regenec )
          per_minute = per_hour.to_f / 60

          all_amount = mins * per_minute    # it's float
          amount = all_amount.truncate      # truncate this value
          if amount > 0
            remain = all_amount - amount
            remain_seconds = (remain / per_minute) * 60

            user.e_health_regenerated_at = t - remain_seconds

            if user.a_health < GameProperties::FIGHT_OPPONENT_MINIMAL_HEALTH
              if amount * GameProperties::FIGHT_HEALTH_REGENERATION_SPEED <= GameProperties::FIGHT_OPPONENT_MINIMAL_HEALTH
                amount *= GameProperties::FIGHT_HEALTH_REGENERATION_SPEED
              end
            end

            user.a_health = [user.a_health + amount, user.max_health].min

            return true
          end
        end
      end
      false
    end

    def adjust_pet?(user)
      if user.pet_is_live?
        if !user.e_pet_health_regenerated_at
          user.e_pet_health_regenerated_at = Time.now
          return true
        else
          t = Time.now
          mins = (t - user.e_pet_health_regenerated_at).seconds_to_minutes
          if mins >= 10
            per_hour = user.pet_health_hour_regeneration
            per_minute = per_hour.to_f / 60

            all_amount = mins * per_minute    # it's float
            amount = all_amount.truncate      # truncate this value
            if amount > 0
              remain = all_amount - amount
              remain_seconds = (remain / per_minute) * 60

              user.e_pet_health_regenerated_at = t - remain_seconds

              user.pet_health += amount

              return true
            end
          end
        end
      end
      false
    end
  end
end

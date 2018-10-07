class HomeRules < AbstractRules

  def self.can_meditate(user, time)
    r = Rule.new

    if time.nil?
      r.message = tg(:strange_situation)
      return r
    end

    if time == 0
      r.message = tg(:strange_situation)
      return r
    end

    if time < 0 || time > GameProperties::MEDITATION_MAX_TIME
#      BanHistory.ban_hack!(user, "meditate time: #{time}")
      r.message = tg(:strange_situation)
      return r
    end

    if user.meditating?
      r.message = t(:meditating,
        {
          :remain => (user.meditation_finished_at - Time.now).seconds_to_full_time
        }
      )
      return r
    end

#    max_time = Inventories::HouseInventory::HORSE.get_max_time user
#    max_time_to_go = [max_time - user.patrol_total_time, 0].max

#    max_time = GameProperties::MEDITATION_MAX_TIME
#    day_meditation = user.day_meditation_time || 0
#    max_time_to_go = [max_time - day_meditation, 0].max

#    if max_time_to_go == 0
#      r.message = t(:you_used_all_your_time)
#      return r
#    end

#    if time > max_time_to_go
#      r.message = t(:you_can_go_only, :time => max_time_to_go.seconds_to_minutes)
#      return r
#    end

    r
  end

  def self.can_cancel_meditate(user)
    r = Rule.new

     if !user.meditating?
      r.message = tg(:strange_situation)
      return r
    end
    r
  end
  
end

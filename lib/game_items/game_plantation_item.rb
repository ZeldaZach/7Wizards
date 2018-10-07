class GamePlantationItem < AbstractGameLevelItem

  KEY = 'plantation'

  def self.adjust?(user)

    # plantation is not working when user is on holidays
    return if user.on_holiday?

    t = Time.now

    last = user.plantation_updated_at
    if !last
      user.plantation_updated_at = t
      return true
    end

    # plantation item
    level_item = instance.get_user_scale_item user
    per_hour = level_item[:money] || 0
    per_minute = per_hour.to_f / 60.0

    # if user reach max we can't give him more money
#    max_money_ro_receive = get_max_plantation_money(user)

    mins = (t - last).seconds_to_minutes
    if mins >= 10
      all_money = mins * per_minute   # it's float
      money_to_receive = all_money.truncate      # truncate this value
      if money_to_receive > 0
        remain = all_money - money_to_receive
        remain_seconds = (remain / per_minute) * 60

        user.plantation_updated_at = t - remain_seconds
        user.add_money(money_to_receive, "plantation", "plantation")

#        money_to_receive = [(max_money_ro_receive - user.a_money), 0].max if max_money_ro_receive && (user.a_money + money_to_receive > max_money_ro_receive)
#
#        if money_to_receive < 1 && (user.e_sent_max_plantation_msg.nil? || user.e_sent_max_plantation_msg > 1.days.since)
#          user.e_sent_max_plantation = Time.now
#          Message.store_max_mana(user)
#        end
          

        return true
      end
    end

    false
  end

  def self.reset(user)
    n = Time.now
    t = Time.local(n.year, n.month, n.day, n.hour)
    user.plantation_updated_at = t
  end

  protected

  # override
  def parse_scale_item(scale, item)
    local_item = {
      :money => item[0],
      :price => item[1],
      :price_staff => item[2]
    }
    scale << local_item
  end

  def level_scale_item_description(level_item)
    t "#{key}.description_money_per_hour", :money => tp(level_item[:money])
  end

end

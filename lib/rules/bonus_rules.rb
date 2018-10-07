class BonusRules < AbstractRules
  
  def self.cat_get_bonus(user)
    r = Rule.new
    
    if user.daily_bonus_updated_at && user.daily_bonus_updated_at.tomorrow > 1.hours.since
      remain = (user.daily_bonus_updated_at.tomorrow - 1.hours.since).seconds_to_full_time
      r.message = t(:nextbonus, :time => remain )
      return r
    end 
    r
  end

end

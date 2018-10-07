class Schedule::DragonPlanner < Schedule::Base

  def self.plan_arrival
    return if Dragon.planned_today?

    #    if Dragon.last_planned.arrived_at > 3.days.ago || rand < GameProperties::DRAGON_ARRIVE_PROBABILITY.to_percent
    date = Date.today
    date = date.to_time + GameProperties::DRAGON_ARRIVE_FROM +
      rand(GameProperties::DRAGON_ARRIVE_TO - GameProperties::DRAGON_ARRIVE_FROM)

    Helpers::DragonHelper.create_dragon date
    #    end

  end

  def self.check
    Helpers::DragonHelper.fly_away_dragon
  end
  
  self.redefine(self)

end

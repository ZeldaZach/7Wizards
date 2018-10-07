class AchivementDamage < AbstractAchivement

  KEY = "damage"

  def adjust(user, fight_log)
    value = fight_log.user == user ? fight_log.opponent_health_diff : fight_log.user_health_diff
    r = super(user, value)
    r
  end
  
end

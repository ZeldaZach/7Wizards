class AchivementStealer < AbstractAchivement

  KEY = "stealer"

  def adjust(user, fight_log)
    value = fight_log.winner == user ? fight_log.winner_money_diff.abs : 0
    r = super(user, value)
    r
  end
  
end

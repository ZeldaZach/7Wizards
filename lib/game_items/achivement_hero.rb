class AchivementHero < AbstractAchivement

  KEY = "hero"

  def adjust(user, fight_log)
    value = fight_log.winner == user ? fight_log.winner_reputation : 0
    r = super(user, value)
    r
  end

end


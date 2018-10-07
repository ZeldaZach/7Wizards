class AchivementChampion < AbstractAchivement

  KEY = "champion"
  
  def adjust(user, fight_log)
    value = fight_log.winner == user ? 1 : 0
    r = super(user, value)
    r
  end

end


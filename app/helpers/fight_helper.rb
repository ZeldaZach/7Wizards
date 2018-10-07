module FightHelper

  def user_won(user, fight_log)
    return fight_log.winner == user
  end

  def user_lose(user, fight_log)
    return fight_log.loser == user
  end

  def winner_name(fight_log)
    return fight_log.winner_a.name if fight_log.winner_a
    return fight_log.winner.name if fight_log.winner
    t(:fight_unknown)
  end

  def loser_name(fight_log)
    return fight_log.loser_a.name if fight_log.loser_a
    return fight_log.loser.name if fight_log.loser
    t(:fight_unknown)
  end

  def winner_pet_health_label(f)
    health = f.winner_pet_health_after_fight
    if !health.nil?
      r = f.winner_pet_reanimate
      return r > 0 ? "#{health}#{tv(:pet_reanimate_label, :amount => r)}" : health
    end
    ""
  end

  def loser_pet_health_label(f)
    health = f.loser_pet_health_after_fight
    if !health.nil?
      r = f.loser_pet_reanimate
      return r > 0 ? "#{health}#{tv(:pet_reanimate_label, :amount => r)}" : health
    end
    ""
  end

end 
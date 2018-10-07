class AchivementPetKills < AbstractAchivement
  KEY = 'pet_kills'

  def adjust(user, fight_log)
    return if fight_log.user == user && !user.can_receive_bonus_for_kill_pet?(fight_log.opponent)

    if fight_log.pet_fight && (fight_log.loser_pet_killed || fight_log.winner_pet_killed)

      if (fight_log.loser_pet_killed && fight_log.winner == user) ||
          (fight_log.winner_pet_killed && fight_log.winner != user)
        value = 1
      else
        value = 0
      end
    end
    r = super(user, value)
    r
  end

end

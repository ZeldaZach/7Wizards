# serialized in fight log
# related to user and stored as collection per user
class FightExt::FightRoundDetail

  attr_accessor :user, # boolean it's true when it's user record and false if opponent
      :damage, :real_damage, # damage is damage what we'll remove from user health it can be more then user health.
      :blocked_damage, :critical, :stroke, :details,
      :amulet_pups_opponent, :amulet_kakdams_user,
      :pet_damage, :pet_fight, :pet_killed, :anti_pet_opponent
    
  def user_name(fight_log)
    user ? fight_log.user_a.name : fight_log.opponent_a.name
  end

  def opponent_name(fight_log)
    user ? fight_log.opponent_a.name : fight_log.user_a.name
  end

  def damage?
    self.damage && self.damage > 0
  end

  def pet_damage?
    self.pet_damage && self.pet_damage > 0
  end

  def only_user_damage
    r = 0
    if self.damage?
      r = self.pet_damage? ? self.damage - self.pet_damage : self.damage
    end
    r
  end

  def pet_fight?
    self.pet_fight == true
  end

  def pet_killed?
    self.pet_killed == true
  end

  def amulet_pups_opponent?
    amulet_pups_opponent == true
  end

  def amulet_kakdams_user?
    amulet_kakdams_user == true
  end

  def anti_pet_opponent?
    anti_pet_opponent == true
  end


end

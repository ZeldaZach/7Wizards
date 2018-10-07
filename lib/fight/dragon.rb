class Fight::Dragon < Fight::Standard

  attr_reader :dragon

  def initialize(user, dragon)
    @dragon = dragon
    @opponent_a = dragon.user_attributes

    super(user, dragon.user)
    
    f.dragon = dragon
  end

  # override
  def fight!
    fight

    FightLog.transaction do
      if f.opponent_health_diff > 0
        attacker = dragon.get_attacker(user)
        attacker.damage += f.opponent_health_diff

        unless attacker.attacks_count
          attacker.attacks_count = 1
        else
          attacker.attacks_count += 1
        end
        AllGameItems::ACHIVEMENT_DRAGONS.extend(user, f.opponent_health_diff)
        attacker.save!
      end

      user.register_activity 'fight dragon'

      f.save!
      user.save!
    end

    user.e_register_fight f
    
    f
  end

  # override
  def fight_update_result_money
    # we should not distribute money for dragon fight ...
    f.winner_money_diff = 0
    f.loser_money_diff = 0
  end

  def fight_update_result_experience_and_reputation
    f.winner_experience = 0
    f.winner_reputation = 0
  end
  
end

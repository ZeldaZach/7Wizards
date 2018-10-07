class Fight::ClanWar < Fight::Standard

  def initialize(user, opponent)
    @user_a = user.user_attributes( :fight_user => true, :clan_war => true, :opponent => opponent ) unless @user_a
    @opponent_a = opponent.user_attributes( :fight_opponent => true, :clan_war => true, :opponent => user ) unless @opponent_a
    
    super(user, opponent)

    @f.clan_war = true
  end

  # override
  def fight!
    r = super
    Services::War.check_status_after_fight @user.current_war
    r
  end

  # override
  def fight_update_result_health(user_health, opponent_health)
    
    super(user_health, opponent_health)

    user_health_diff = @f.user_won ? @f.winner_health_diff : @f.loser_health_diff
    opponent_health_diff = @f.user_won ? @f.loser_health_diff : @f.winner_health_diff

    u = @f.user.current_clan_war_user
    u.damage += opponent_health_diff
    u.lost_protection += user_health_diff
    u.fights += 1
    u.attacks += 1
    u.wins += 1 if @f.user_won
    u.save!

    u = @f.opponent.current_clan_war_user
    u.damage += user_health_diff
    u.lost_protection += opponent_health_diff
    u.fights += 1
    u.wins += 1 if !@f.user_won
    u.save!
  end

  # override
  def fight_update_result_experience_and_reputation
    super

    # on war we should not decrease reputation, so we should rollback reputation change
    if @f.winner_reputation < 0
      w = @f.winner
      w.a_reputation -= @f.winner_reputation
    end
  end

end

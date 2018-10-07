# TODO, is not used now, but should be used when we add clan unions

class Fight::ClanUnion < Fight::Standard

  # override
  def fight!
    r = super
#        if f.winner_union_fight?
#          Fight::War.check_status_after_fight f.loser.current_war
#        end
#        if f.loser_union_fight?
#          Fight::War.check_status_after_fight f.winner.current_war
#        end
#      end
    r
  end

  # override
  def fight_update_result_health(user_health, opponent_health)

    super(user_health, opponent_health)

    user_health_diff = @f.user_won ? @f.winner_health_diff : @f.loser_health_diff
    opponent_health_diff = @f.user_won ? @f.loser_health_diff : @f.winner_health_diff

#      if f.user.on_union_war?(f.opponent)
#        if opponent_health_diff > 0
#          u = f.opponent.current_clan_war_user
#          u.lost_protection += opponent_health_diff
#          u.union_fights += 1
#          u.union_wins += 1 if !f.user_won
#          u.save!
#        end
#        f.user_union_fight = true
#      end
#      if f.opponent.on_union_war?(f.user)
#        if user_health_diff > 0
#          u = f.user.current_clan_war_user
#          u.lost_protection += user_health_diff
#          u.union_fights += 1
#          u.union_wins += 1 if f.user_won
#          u.save!
#        end
#        f.opponent_union_fight = true
#      end
  end

end

class Services::War

  class << self
    
    def start_war(clan, opponent_clan)
      war = ClanWar.new(
        :clan => clan,
        :clan_owner => clan.owner,
        :opponent_clan => opponent_clan,
        :opponent_clan_owner => opponent_clan.owner,
        :started_at => Time.now + GameProperties::CLAN_WAR_PREPARATION_TIME
      )

      war.transaction do
        war.save!

        prepare_war_users(war, clan)
        prepare_war_users(war, opponent_clan, true)
        
        ClanMessage.log_war_started war
      end
    end

    # called by scheduler
    def check_status_by_time(war)

      return if !war || war.reload.finished?

      if war.started_at < GameProperties::CLAN_MAX_WAR_DURATION_TIME.ago
        clan_protection = war.clan_protection_remain
        opponent_clan_protection = war.opponent_clan_protection_remain
        war.clan_won = clan_protection > opponent_clan_protection

        finish_war(war, ClanWar::FINISH_REASON_TIME)
      end
    end

    # user can't fight if:
    # 1. he is not active
    # 2. he is on holiday
    # 3. he has not enought health
    def check_status_by_parameters(war)

      return if !war || war.reload.finished?

      all_cant_fight = proc do |war, clan|
        r = true
        users = war.clan_users(clan)
        users.each do |u|
          u = u.user
          if u && !u.on_holiday? && u.active && u.a_health >= GameProperties::CLAN_WAR_MIN_HEALTH_FOR_WIN
            r = false
            break
          end
        end
        r
      end

      end_war = false
      if all_cant_fight.call(war, war.clan)
        war.clan_won = false
        end_war = true
      else
        if all_cant_fight.call(war, war.opponent_clan)
          war.clan_won = true
          end_war = true
        end
      end

      if end_war
        finish_war(war, ClanWar::FINISH_REASON_PARAMETERS)
      end
    end

    # called after fight
    def check_status_by_protection(war)

      return if !war || war.reload.finished?

      end_war = false
      remain = war.clan_protection_remain
      if remain > 0
        remain = war.opponent_clan_protection_remain
        if remain <= 0
          war.clan_won = true
          end_war = true
        end
      else
        war.clan_won = false
        end_war = true
      end

      if end_war
        finish_war(war, ClanWar::FINISH_REASON_PROTECTION)
      end
    end

    def check_status_after_fight(war)
      self.check_status_by_protection war
      self.check_status_by_parameters war
    end

    def reset_war(war)
      war.transaction do
        reset_war_users war.clan_users
        reset_war_users war.opponent_clan_users

        war.clan.save!
        war.opponent_clan.save!

        war.clan_id = -war.clan_id
        war.opponent_clan_id = -war.opponent_clan_id
        war.save!
      end
    end

    def reset_war_users(users)
      users.each do |war_user|
        u = war_user.user
        if u && u.current_clan_war_user && u.current_clan_war_user == war_user
          u.current_clan_war_user = nil
          u.save!
        end
      end
    end

    private

    # reason is one of :time, :protection, :parameters
    def finish_war(war, reason)

      return false if !war || war.finished?

      RedisLock.lock "finish_war_#{war.id}" do

        winner = war.winner_clan
        loser = war.loser_clan

        winner_users = war.winner_users
        loser_users = war.loser_users

        war.winner_money = (loser.a_money.to_f / 2).to_i
        loser.a_money -= war.winner_money

        war.winner_staff2 = (loser.a_staff2.to_f / 2).to_i
        loser.a_staff2 -= war.winner_staff2
        winner.a_staff2 += war.winner_staff2

        if war.opponent_clan.has_altar? || war.opponent_clan == war.winner_clan
          distribute_war_winner_reputation(winner_users)
        end
        
        if loser.has_altar?
          war.winner_money += loser.altar_price
          loser.g_clan_altar = 0
        end

        winner.a_money += war.winner_money

        update_achivement_stats(winner_users)
        update_clan_war_statistics(war)

        war.finished_at = Time.now
        war.finish_reason = reason.to_s

        
        war.transaction do
          reset_war_users(winner_users)
          reset_war_users(loser_users)

          winner.save!
          loser.save!
          war.save!
          
          ClanMessage.log_war_finished war
        end

        return true
      end

      false
    end

    def prepare_war_users(war, clan, is_opponent = false)
      clan.users.each do |user|
        raise "clan user is already defined: id: #{user.current_clan_war_user.id}" if user.current_clan_war_user

        if !user.active || user.on_holiday?
          protection = 0
        else
          max_health = HealthGrowthTable.get_max_health(user, false, :use_clear_attributes => true)
          coef = is_opponent ? GameProperties::CLAN_WAR_PROTECTION_COEFICIENT_OPPONENT : GameProperties::CLAN_WAR_PROTECTION_COEFICIENT
          protection = max_health * coef
        end

        u = ClanWarUser.create(
          :war => war,
          :user => user,
          :clan => clan,
          :protection => protection,
          :damage => 0,
          :lost_protection => 0
        )
        user.current_clan_war_user = u
        user.save!
      end
    end

    def distribute_war_winner_reputation(winner_users)
      winner_users.each do |war_user|
        u = war_user.user
        if u
          u.a_reputation += GameProperties::CLAN_WAR_WINNER_REPUTATION_BONUS
        end
      end
    end

    def update_achivement_stats(winner_users)
      winner_users.each do |war_user|
        u = war_user.user
        if u
          AllGameItems::ACHIVEMENT_WON_WARS.extend(u, 1)
        end
      end
    end

    def update_clan_war_statistics(war)
      winner = war.winner_clan
      winner.s_wins_count += 1
      winner.s_loot_money += war.winner_money
      winner.s_loot_staff2 += war.winner_staff2

      loser = war.loser_clan
      loser.s_loses_count += 1
      loser.s_lost_money += war.winner_money
      loser.s_lost_staff2 += war.winner_staff2

    end
    
  end

end
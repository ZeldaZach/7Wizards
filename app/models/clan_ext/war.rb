module ClanExt
  module War

    def has_altar?
      self.g_clan_altar > 0
    end

    def altar_price
      self.has_altar? ? AllClanItems::ALTAR.get_level_price(self.g_clan_altar - 1)[:price] : 0
    end

    def amount_of_wars_per_month
      AllClanItems::ALTAR.get_level_value(self.g_clan_altar)
    end

    def on_war?
      !current_war.nil?
    end

    def current_war
      self.owner.current_war
    end

    def current_war_opponent_clan
      war = current_war
      return nil if !war

      war.clan == self ? war.opponent_clan : war.clan
    end

    # with altar we can start war. we are losing altar when we lose war
    # we should calculate how mutch wars we started from last lose
    def get_current_month_altar_started_wars_count
      return 0 if !self.has_altar?

      r = 0
      t = Time.now.beginning_of_month

      wars = ClanWar.all :conditions => ['(clan_id = ? or opponent_clan_id = ?) and started_at >= ?', self.id, self.id, t],
        :order => 'started_at desc'

      wars.each do |war|
        break if !war.winner?(self)
        r += 1 if war.clan == self
      end

      r
    end

    def get_current_month_started_wars_by_other_clans_count
      t = Time.now.beginning_of_month
      ClanWar.count :conditions => ['opponent_clan_id = ? and started_at >= ?', self.id, t],
        :order => 'started_at desc'
    end

    def get_last_started_war
      ClanWar.first :conditions => ['clan_id = ?', self.id], :order => 'started_at desc'
    end

    def get_last_war
      ClanWar.first :conditions => ['(clan_id = ? or opponent_clan_id = ?)', self.id, self.id], :order => 'started_at desc'
    end

    def get_last_war_with_rest
      last_war = get_last_war
      last_war && last_war.war_with_rest? ? last_war : nil
    end

    def get_last_started_war_with_clan(clan)
      ClanWar.first :conditions => ['clan_id = ? and opponent_clan_id = ?', self.id, clan.id],
        :order => 'started_at desc'
    end

    def get_active_users_power
      conditions = User.apply_active_conditions ['clan_id = ?', self.id]
      User.sum :a_power, :conditions => conditions
    end

    def get_users_protection
      User.sum :a_protection, :conditions => [ 'clan_id = ?', self.id ]
    end

    def get_last_wars_history
      ClanWar.all :conditions => ['(clan_id = ? or opponent_clan_id = ?)', self.id, self.id], :order => 'started_at desc', :limit => 10
    end
  end
end


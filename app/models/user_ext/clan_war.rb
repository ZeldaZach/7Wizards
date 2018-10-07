module UserExt
  module ClanWar

    def current_war
      self.current_clan_war_user ? self.current_clan_war_user.war : nil
    end

    def on_war?
      self.current_war != nil
    end

    def on_started_war?
      war = self.current_war
      war ? war.started? : false
    end

    def on_war_with_user?(user)
      self.clan != user.clan &&
        self.on_war? &&
        self.current_war == user.current_war &&
        self.current_war.started?
    end

    # will true when we count user as killed on war
    def non_active_for_attacks_on_war?
      self.on_holiday? || !self.active ||
        self.a_health < GameProperties::FIGHT_OPPONENT_MINIMAL_HEALTH ||
        UserItems::ShopGiftWarHidden.hidden_on_war?(self)
    end

    def active_for_attacks_on_war?
      !non_active_for_attacks_on_war?
    end

  end
end

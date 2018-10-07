class ClanWar < ActiveRecord::Base

  # include base mode behaviour
  include BaseModel

  belongs_to :clan
  belongs_to :clan_owner, :class_name => 'User', :foreign_key => 'clan_owner_id'
  
  belongs_to :opponent_clan, :class_name => 'Clan', :foreign_key => 'opponent_clan_id'
  belongs_to :opponent_clan_owner, :class_name => 'User', :foreign_key => 'opponent_clan_owner_id'

  FINISH_REASON_TIME = 'time'             # war is finished because of time restriction
  FINISH_REASON_PARAMETERS = 'parameters' # war is finished because all users can't fight
  FINISH_REASON_PROTECTION = 'protection' # all protection were broken

  def get_opponent_clan(clan)
    return self.opponent_clan if clan == self.clan
    return self.clan if clan == self.opponent_clan
    nil
  end

  def winner_clan
    return nil if self.clan_won.nil?
    self.clan_won ? self.clan : self.opponent_clan
  end

  def winner?(clan)
    finished? && winner_clan == clan
  end

  def loser_clan
    return nil if self.clan_won.nil?
    self.clan_won ? self.opponent_clan : self.clan
  end

  def winner_users
    return nil if self.clan_won.nil?
    clan_users(self.winner_clan)
  end

  def loser_users
    return nil if self.clan_won.nil?
    clan_users(self.loser_clan)
  end

  def clan_users(clan = nil, order = 'damage desc')
    clan ||= self.clan
    ClanWarUser.all :conditions => ['war_id = ? and clan_id = ?', self.id, clan.id], :order => order
  end

  def opponent_clan_users(order = 'damage desc')
    clan_users self.opponent_clan, order
  end

  def clan_formation_users(clan, formation)
    if ClanWarUser::FORMATIONS.include? formation
      conditions = ['war_id = ? and clan_id = ? and formation = ?', self.id, clan.id, formation]
    else
      conditions = ['war_id = ? and clan_id = ? and formation is null', self.id, clan.id]
    end
    ClanWarUser.all :conditions => conditions
  end

  def clan_protection(clan = nil)
    clan ||= self.clan

    sql = <<-SQL
      SELECT SUM(protection)
      FROM clan_war_users
      WHERE clan_id = #{clan.id} AND war_id = #{self.id}
    SQL

    self.select_value(sql).to_i
  end

  def opponent_clan_protection(clan = nil)
     clan_protection clan || self.opponent_clan
  end

  def clan_damage(clan = nil)
    clan ||= self.clan

    sql = <<-SQL
      SELECT SUM(damage)
      FROM clan_war_users
      WHERE clan_id = #{clan.id} AND war_id = #{self.id}
    SQL

    self.select_value(sql).to_i
  end

  def opponent_clan_damage(clan = nil)
     clan_damage clan || self.opponent_clan
  end

  def clan_lost_protection(clan = nil)
    clan ||= self.clan

    sql = <<-SQL
      SELECT SUM(lost_protection)
      FROM clan_war_users
      WHERE clan_id = #{clan.id} AND war_id = #{self.id}
    SQL

    self.select_value(sql).to_i
  end

  def opponent_clan_lost_protection(clan = nil)
     clan_lost_protection clan || self.opponent_clan
  end

  def clan_protection_remain(clan = nil)
     [clan_protection(clan) - clan_lost_protection(clan), 0].max
  end

  def opponent_clan_protection_remain(clan = nil)
     [opponent_clan_protection(clan) - opponent_clan_lost_protection(clan), 0].max
  end

  # how much damage my unions did opponent clan
  def clan_unions_damage(clan)
    if clan == self.clan
      lost_protection = opponent_clan_lost_protection
      damage = clan_damage
    else
      lost_protection = clan_lost_protection
      damage = opponent_clan_damage
    end
    [lost_protection - damage, 0].max
  end

  def clan_on_war?(clan)
    if clan.is_a? Clan
      clan == self.clan || clan == self.opponent_clan
    else
      clan && (clan == self.clan.id || clan == self.opponent_clan.id)
    end
  end

  def started?
    self.started_at <= Time.now
  end

  def finished?
    self.finished_at != nil
  end

  def war_with_rest?
    !self.finished? || self.finished_at > GameProperties::CLAN_REST_TIME_AFTER_WAR.ago
  end

  def finish_reason_string(clan)
    if finished?
      r = self.finish_reason ? self.finish_reason : FINISH_REASON_PROTECTION
      if self.winner?(clan)
        ClanWar.t("finish_reason_winner_#{r}".to_sym)
      else
        ClanWar.t("finish_reason_loser_#{r}".to_sym)
      end
    else
      nil
    end
  end

end

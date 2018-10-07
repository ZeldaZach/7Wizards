class ClanWarUser < ActiveRecord::Base

  include BaseModel

  require 'ar-deltas'

  belongs_to :war, :class_name => 'ClanWar'
  belongs_to :clan  
  belongs_to :user

  FORMATION_LEFT = 'l'
  FORMATION_RIGHT = 'r'
  FORMATION_CENTER = 'c'
  FORMATIONS = [FORMATION_LEFT, FORMATION_RIGHT, FORMATION_CENTER]

  validates_inclusion_of :formation, :in => FORMATIONS, :allow_nil => true

  delta_attributes :damage, :lost_protection, :fights, :attacks, :wins, :union_fights, :union_wins

  # used for virtual users, like towers and dragons
  def self.find_current_war_virtual_user(clan, kind)
    war = clan.current_war
    return nil if !war
    find :first, :conditions => { :clan_id => clan, :war_id => war, :kind => kind }
  end

  # used for virtual users, like towers and dragons
  def self.find_current_wars_virtual_users(kind)
    sql = <<-SQL
      select u.*
      from clan_war_users u
      join clan_wars w on u.war_id = w.id
      where w.finished_at is null and w.started_at < ? and u.kind = ?
    SQL
    ClanWarUser.find_by_sql [sql, Time.now, kind]
  end

  def virtual?
    user_id.nil? || !kind.nil?
  end

  def building?
    kind && Inventories::ClanWarItems::BUILDING_KEYS.include?(kind)
  end

  def dragon?
    kind && Inventories::ClanWarItems::DRAGON_KEYS.include?(kind)
  end

  def name
    return Inventories::ClanWarItems.get_item(kind).title if building? || dragon?
    nil
  end

end

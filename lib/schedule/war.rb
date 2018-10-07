class Schedule::War

  def self.check
    finish_wars_by_time
    finish_wars_by_parameters
  end

  def self.finish_wars_by_time
    wars = ClanWar.all(:conditions => ['finished_at is null and started_at < ?',
        GameProperties::CLAN_MAX_WAR_DURATION_TIME.ago])
    wars.each do |war|
      Services::War.check_status_by_time(war)
    end
  end

  def self.finish_wars_by_parameters
    wars = ClanWar.all(:conditions => 'finished_at is null')
    wars.each do |war|
      Services::War.check_status_by_parameters(war)
    end
  end

#  # we should execute this task often because towers should fight
#  # clans every 10 minutes
#  def self.building_fight
#    Inventories::ClanWarTowerItem.fight
#  end
  
end

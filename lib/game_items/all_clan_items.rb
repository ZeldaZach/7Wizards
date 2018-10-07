class AllClanItems

  PLACES = ClanPlacesItem.new
  POWER = ClanPowerItem.new
  PROTECTION = ClanProtectionItem.new
  ALTAR = ClanAltarItem.new
#  ACADEMY = ClanAcademyItem.new

  ALL = [PLACES, ALTAR, POWER, PROTECTION]

  def self.all
    ALL
  end

  def self.get(key)
    ALL.each do |i|
      return i if i.key == key
    end
    nil
  end

end

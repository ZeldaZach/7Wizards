class AllGameItems

  FENCE = GameFenceItem.new
#  PLACES = GamePlacesItem.new
  PLANTATION = GamePlantationItem.new
  SAFE = GameSafeItem.new
  SAFE2 = GameSafe2Item.new
  CLAIRVOYANCE = GameClairvoyanceItem.new
  CLOAKING = GameCloakingItem.new

  ENDURANCE = GameEnduranceItem.new
  POWER = GamePowerItem.new
  PROTECTION = GameProtectionItem.new
  VOODOO = GameVoodooItem.new

  PET_POWER = GamePetPowerItem.new
  ANTIPET = GameAntipetItem.new
  ANTIKILLER = GamePetAntikillerItem.new


  PROFILE = [FENCE, PLANTATION, CLAIRVOYANCE, CLOAKING]
  POWER_UP = [ENDURANCE, POWER, PROTECTION, SAFE, VOODOO, PET_POWER, ANTIPET, ANTIKILLER]

  PET_POWERUPS  = [ANTIKILLER, PET_POWER]

  ALL = PROFILE + POWER_UP

  ACHIVEMENT_ELDERS     = AchivementElders.new
  ACHIVEMENT_MEDITATION = AchivementMeditation.new
  ACHIVEMENT_STEALER    = AchivementStealer.new
  ACHIVEMENT_CHAMPION   = AchivementChampion.new
  ACHIVEMENT_DAMEGE     = AchivementDamage.new
  ACHIVEMENT_HERO       = AchivementHero.new
  ACHIVEMENT_PET_KILLS  = AchivementPetKills.new
  ACHIVEMENT_WON_WARS   = AchivementWonWars.new
  ACHIVEMENT_DRAGONS    = AchivementDragons.new
  ACHIVEMENT_GIFTS      = AchivementGifts.new

  
  ALL_ACHIVEMENTS = [ACHIVEMENT_ELDERS, ACHIVEMENT_MEDITATION, ACHIVEMENT_STEALER,
                      ACHIVEMENT_CHAMPION, ACHIVEMENT_DAMEGE, ACHIVEMENT_HERO, ACHIVEMENT_PET_KILLS,
                      ACHIVEMENT_WON_WARS, ACHIVEMENT_DRAGONS, ACHIVEMENT_GIFTS]

  def self.all
    ALL
  end

  def self.power_up
    POWER_UP
  end

  def self.profile
    PROFILE
  end

  def self.get(key)
    ALL.each do |i|
      return i if i.key == key
    end
    nil
  end

  def self.get_achivement(key)
    ALL_ACHIVEMENTS.each do |i|
      return i if i.key == key
    end
    nil
  end

end
class AllTutorials
  
#  NAVIGATIONS = TutorialNavigation.new
  TRAIN       = TutorialTrain.new
  MANA        = TutorialMana.new
  SHOP        = TutorialShop.new
  EQUIPMENT   = TutorialEquipment.new
  FIGHT       = TutorialFight.new
  MEDITATION  = TutorialMeditation.new
  HALLOFGLORY = TutorialHallofglory.new
  DAILYBONUS  = TutorialDailybonus.new
  POWERUPS    = TutorialPowerups.new
  FRIENDS     = TutorialFriends.new
  MESSAGE     = TutorialMessage.new
  ABOUTME     = TutorialAboutme.new
  DRESSUP     = TutorialDressup.new
  GIFTS       = TutorialGifts.new
  CURSES      = TutorialCurses.new
#  PLAYGAME    = TutorialPlaygame.new
#  BLOG        = TutorialBlog.new
  FLAGGING    = TutorialFlagging.new
  ADDITIONAL  = TutorialAdditionaltalents.new
  CLAN        = TutorialClan.new
  
  #user receive gift
  LAST_TASK   = TutorialLastTask.new

  ALL = [TRAIN, MANA, SHOP, EQUIPMENT, FIGHT, MEDITATION, HALLOFGLORY, DAILYBONUS, POWERUPS,
          FRIENDS, MESSAGE, ABOUTME, DRESSUP, GIFTS, CURSES, FLAGGING, ADDITIONAL, CLAN, LAST_TASK]

  
  def self.all
    ALL
  end

  def self.get(key)
    ALL.each do |i|
      return i if i.name == key
    end
    nil
  end

end

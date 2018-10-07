class GamePetAntikillerItem < AbstractGameTimeItem

  KEY = 'pet_antikiller'

  # override
  def can_extend?(user)
    r = super(user)
    if r.allow?
      times = GamePetAntikillerItem.used_this_month(user)
      if times >= GameProperties::GAME_PET_ANTIKILLER_MONTH_USE_LIMITATION
        r.message = tr(:pet_health_limitation_reached, :limit => GameProperties::GAME_PET_ANTIKILLER_MONTH_USE_LIMITATION)
        return r
      end
    end
    r
  end
  
  def reanimate(user, health)
    if user.pet_is_dead? && is_active?(user)
      if UserItems::ShopCurseAntiPet.fired?(user)
        # send event to user about death of his per.
        Message.create_fight_kill_pet_curse(user)
      else
        user.pet_health = health
        return true
      end
    end
    false
  end

  def self.used_this_month(user)
    PaymentLog.count :conditions => ["kind = ? and user_id = ? and created_at > ? and reason = 'pet_antikiller'",
      PaymentLog::SPEND_STAFF, user.id, Time.now.beginning_of_month]
  end

  def description(user = nil)
    d = super
    d += " #{tr(:used_this_moth, :count =>GamePetAntikillerItem.used_this_month(user), :max => GameProperties::GAME_PET_ANTIKILLER_MONTH_USE_LIMITATION)}"
    d
  end
  
end

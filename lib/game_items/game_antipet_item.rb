class GameAntipetItem < AbstractGameTimeItem
  KEY = 'antipet'

  # override
  def can_extend?(user)
    r = super(user)
    if r.allow?
      times = GameAntipetItem.used_this_month(user)
      if times >= GameProperties::GAME_PET_ANTIPET_MONTH_USE_LIMITATION
        r.message = tr(:antipet_limitation_reached, :limit => GameProperties::GAME_PET_ANTIPET_MONTH_USE_LIMITATION)
        return r
      end
    end
    r
  end

  def self.used_this_month(user)
   PaymentLog.count :conditions => ["kind = ? and user_id = ? and created_at > ? and reason = 'antipet'",
      PaymentLog::SPEND_STAFF, user.id, Time.now.beginning_of_month]
  end

  def description(user = nil)
    d = super
    d += " #{tr(:used_this_moth, :count => GameAntipetItem.used_this_month(user), :max => GameProperties::GAME_PET_ANTIPET_MONTH_USE_LIMITATION)}"
    d
  end

end

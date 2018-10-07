class GameVoodooItem < AbstractGameTimeItem
  
  KEY = 'voodoo'

  def description(user = nil)
    d = t description_translate_key, :times => GameProperties::GAME_VOODOO_MONTH_USE_LIMITATION
    d += " #{tr(:used_this_moth, :count => GameVoodooItem.used_this_month(user), :max => GameProperties::GAME_VOODOO_MONTH_USE_LIMITATION)}"
    d
  end

  # override
  def can_extend?(user)
    r = super(user)
    if r.allow?
      times = GameVoodooItem.used_this_month(user)
      if times >= GameProperties::GAME_VOODOO_MONTH_USE_LIMITATION
        r.message = tr(:voodoo_limitation_reached, :limit => GameProperties::GAME_VOODOO_MONTH_USE_LIMITATION)
        return r
      end
    end
    r
  end

  def self.used_this_month(user)
    PaymentLog.count :conditions => ["kind = ? and user_id = ? and created_at > ? and reason = 'voodoo'",
      PaymentLog::SPEND_STAFF, user.id, Time.now.beginning_of_month]
  end

  def self.add_fight_conditions(conditions)
    conditions[0] += " and (g_voodoo_expired_at < ? or g_voodoo_expired_at is null)"
    conditions << Time.new
    conditions
  end
end

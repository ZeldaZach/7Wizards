class GameProtectionItem < AbstractGameTimeItem

  KEY = 'protection'

  def description(user = nil)
    t description_translate_key, :percent => config[:protection_percents]
  end

  def get_protection(user, full_protection)
    (config[:protection_percents].to_percent * full_protection).round
  end

end

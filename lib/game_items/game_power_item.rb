class GamePowerItem < AbstractGameTimeItem

  KEY = 'power'

  def description(user = nil)
    t description_translate_key, :percent => config[:power_percents]
  end

  def get_power(user, full_power)
    (config[:power_percents].to_percent * full_power).round
  end

end

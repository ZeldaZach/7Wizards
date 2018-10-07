class GameSafeItem < AbstractGameTimeItem

  KEY = 'safe'

  def description(user = nil)
    amount = user ? user_max_safe_money(user) : 0
    r = t description_translate_key, :amount => amount
    level = next_safe_level user.a_level
    if level
      amount = next_safe_level_money user.a_level
      r += t description_translate_key + "_next", :level => level, :amount => amount
    end
    r
  end

  # will return max amount of money in user safe
  def user_max_safe_money(user)
    safe_money = 0
    self.scale.each do |item|
      from_level = item[0].to_i
      to_level = item[1].to_i
      safe_money = item[2].to_i

      break if from_level <= user.a_level && user.a_level <= to_level
    end
    safe_money
  end

  # will return next user level where safe change it's properties
  def next_safe_level(level)
    r = nil
    self.scale.each do |item|
      from_level = item[0].to_i
      if from_level > level
        r = from_level
        break
      end
    end
    r
  end

  # will return next safe level money
  def next_safe_level_money(level)
    r = nil
    self.scale.each do |item|
      from_level = item[0].to_i
      safe_money = item[2].to_i
      if from_level > level
        r = safe_money
        break
      end
    end
    r
  end
  
  def get_unsafe_money(user)
    money = get_user_money(user)
    if is_active?(user)
      safe_money = user_max_safe_money(user)
      money = safe_money >= money ? 0 : money - safe_money
    end
    money
  end

  protected

  def scale
    config[:scale]
  end
  
  def get_user_money(user)
    user.a_money
  end

end

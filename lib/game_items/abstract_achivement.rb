class AbstractAchivement < AbstractGameLevelItem

  CATEGORY = :achivement

  def get_level(user)
    current = get_current_scale(user)
    level = 0
    @scale.each do |value|
      if current >= value
        level += 1
      else
        break
      end
    end
    level
  end

  def get_current_scale(user)
    user[attribute_name] || 0
  end

  def get_max_level
    @scale.size
  end
  
  def can_extend?(user)
    level = get_level(user)
    return level < get_max_level && user.respond_to?(:virtual?) && !user.virtual?
  end

  def adjust(user, value = 0)
    if !value.nil? && value > 0
      user[attribute_name] += value
    end
    user[attribute_name]
  end

  def extend!(user, value = 1)
    extend(user, value)
    user.save!
  end

  def extend(user, value = 1)
    return nil unless can_extend?(user)

    current_level = get_level(user)
    adjust(user, value)
    next_level    = get_level(user)

    if next_level > current_level
      diff = next_level - current_level
      diff.times do |i|
        l = current_level + i + 1
        user.add_staff(bonus_staff(l), "achivement", "achivement.#{key}")
        notifi_user(user, l)
      end
    end
  end

  #TODO
  def notifi_user(user, level)
    Message.create_achivement_event(user, level, title, bonus_staff(level))
    RedisCache.put("achivement_reached_#{user.id}", key)
  end

  def self.accept_notification(user)
    RedisCache.del("achivement_reached_#{user.id}")
  end

  def self.get_new_achivement(user)
    k = RedisCache.get("achivement_reached_#{user.id}")
    AllGameItems.get_achivement(k)
  end

  def bonus_staff(level = 1)
    #TODO
    10 * level
  end

  def reached_max?(user)
    get_level(user) >= get_max_level
  end

  def description(user = nil)
    t description_translate_key, :count => get_level_scale_item(get_level(user))
  end
  
  def in_progress_description(user)
    "#{get_current_scale(user)} / #{get_level_scale_item(get_level(user))}"
  end

  def is_active(user)
    get_level(user) > 0
  end

  def image_url
    "/images/user/g_#{key}.png"
  end

  protected

  def parse_scale_item(scale, item)
    scale << item
  end

  def self.attribute_name
    "g_achivement_#{key}"
  end

end

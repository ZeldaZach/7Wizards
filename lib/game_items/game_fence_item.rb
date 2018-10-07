class GameFenceItem < AbstractGameLevelItem

  KEY = 'fence'

  def get_protection(user, full_protection)    
    level_item = get_user_scale_item(user)

    result = full_protection
    result += level_item[:protection]
    result += (result * level_item[:protection_percent].to_percent).round

    result - full_protection
  end

  protected

  # override
  def parse_scale_item(scale, item)
    local_item = {
      :protection => item[0],
      :protection_percent => item[1],
      :price => item[2]
    }
    scale << local_item
  end

  def level_scale_item_description(level_item)
    if level_item[:protection_percent] > 0
      t "#{key}.description_protection_percent",
        :protection => level_item[:protection], :protection_percent => level_item[:protection_percent]
    else
      t "#{key}.description_protection",
        :protection => level_item[:protection]
    end
  end

end

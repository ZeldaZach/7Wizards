class GameCloakingItem < AbstractGameLevelItem

  KEY = 'cloaking'

  def current_level_description(user)
  end

  def next_level_description(user)
  end
  
  protected

  # override
  def parse_scale_item(scale, item)
    local_item = {
      :price => item
    }
    scale << local_item
  end

end

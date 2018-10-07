class GamePlacesItem < AbstractGameLevelItem

  KEY = 'places'

  def get_places_count(user)
    item = self.get_user_scale_item(user)
    item[:places]
  end

  protected

  # override
  def parse_scale_item(scale, item)
    local_item = {
      :places => item[0],
      :price => item[1]
    }
    scale << local_item
  end

  def level_scale_item_description(level_item)
    t "#{key}.description_places", :places => level_item[:places]
  end

end

class AbstractClanItem < AbstractGameLevelItem

  def get_value(clan)
    level = get_level(clan)
    get_level_value(level)
  end

  def get_value_percent(clan)
    v = get_value(clan)
    v > 0 ? v.to_f / 100 : 0
  end

  def get_level_value(level)
    level_item = get_level_scale_item(level) || get_level_scale_item(get_max_level)
    level_item[:value]
  end

  # override 
  def can_extend?(clan)
    r = super(clan)
    return r if !r.allow?

    if clan.on_war?
      r.message = tg(:strange_situation)
      return r
    end
    
    r
  end

#  def tr(local_key, options = {})
#    local_key = :clan_cant_extend_not_enought_money_on_this_item if local_key == :cant_extend_not_enought_money_on_this_item
#    super(local_key, options)
#  end

  protected

#  def level_description_key
#    "other.clan.improvements.#{key}.level_description"
#  end

  def parse_scale_item(scale, item)
    local_item = {
      :value => item[0],
      :price => item[1]
    }
    scale << local_item
  end

  def level_scale_item_description(level_item)
    t("#{key}.level_description", :value => level_item[:value])
  end

end

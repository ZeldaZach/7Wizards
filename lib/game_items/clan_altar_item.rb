class ClanAltarItem < AbstractClanItem

  KEY = 'clan_altar'

  protected 
  
  def level_scale_item_description(level_item)
    t("#{key}.level_description", :count => level_item[:value])
  end
end

class ShopRules < AbstractRules

  def self.can_buy_item(user, item)
    r = Rule.new

    if UserItem.shop_items(user).length >= GameProperties::GAME_MAX_ITEMS_PLACES
      r.message = t(:not_enought_places, {:places => GameProperties::GAME_MAX_ITEMS_PLACES})
      return r
    end

    return item.can_buy?(user)
  end

  def self.can_sell_item(user, item)
    r = Rule.new

    if user.uses_item?(item.key)
      r.message = t(:sell_use_item)
      return r
    end

    item.can_sell?(user)
  end

  def self.can_extend_item(user, item)
    r = Rule.new

    unless item
      r.message = tg(:strange_situation)
      return r
    end

    item.can_extend?(user)
  end

end

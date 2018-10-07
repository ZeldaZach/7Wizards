class UserItems::AbstractLevelUserItem < UserItem

  def required_level
    self.class.required_level
  end

  # needed for acts_like calls
  def self.acts_like_level_item?
    true
  end

  def self.can_extend?(user)
    r = Rule.new

    unless has? user
      r.message = tr(:cant_extend_you_dont_have_this_item)
      return r
    end

    if !check_price user
      p = get_price(user)
      if p.is_money?
        r.message = tr(:cant_extend_not_enought_money_on_this_item)
      elsif p.is_staff2?
        r.message = tr(:cant_extend_not_enought_staff2_on_this_item)
      else
        r.message = tr(:cant_extend_not_enought_staff_on_this_item)
      end
      return r
    end

    level = get_level(user)
    if level >= get_max_level
      r.message = tr(:cant_extend_reach_max_level)
    end

    r
  end

  # override
  def self.buy(user)
    item = super(user)
    if item && item.level == 0
      item.level = 1
    end
  end

  def self.extend(user)
    item = get user
    if item
      item.level += 1
      price = get_price(user)
      if price.pay(false, "shop_level_items")
        return item
      end
    end
    nil
  end

  # override
  def self.get_level(user)
    item = get user
    item ? item.level : 0
  end

  # override
  def self.get_max_level
    @config_max_level || 0
  end

  # should return description of item for next level
  def next_description(user=nil)
    description(user)
  end
end

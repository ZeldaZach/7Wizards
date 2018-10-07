class PetRules < AbstractRules

  def self.can_train_attribute(user, attribute)

    r = Rule.new

    value = user['pet_' + attribute]
    if !value || !user.has_pet?
      r.message = tg(:strange_situation)
      return r
    end

    price = UserAttributesGrowthTable.get_price(user, attribute.intern, true)

    if (!price || price == 0)
      r.message = tg(:strange_situation)
      return r
    end

    if user.a_money < price
      r.message = t(:not_enought_money)
      return r
    end

    r
  end

  def self.can_buy(user, pet_kind)
    r = Rule.new

    price = Price.new(user, 0, user.has_pet? ? GameProperties::PET_REANIMATE_PRICE_STAFF :
        GameProperties::PET_BUY_PRICE_STAFF, 0)

    if !price.acceptable?
      r.message = t(:not_enought_staff, :price => price.price_staff)
      return r
    end

    r
  end

  def self.can_activate(user, value)
    r = Rule.new
#    if value && user.pet_weight < GameProperties::PET_MIN_WEIGHT_TO_PUT_OUT
#      r.message = t(:pet_weight_to_low, :weight => GameProperties::PET_MIN_WEIGHT_TO_PUT_OUT)
#      return r
#    end

    if !user.has_pet? || user.pet_is_dead?
      r.message = tg(:strange_situation)
      return r
    end

    if UserItems::ShopCursePetCage.active?(user)
      r.message = t(:cant_activate_pet_because_of_curse)
      return r
    end

    r
  end

end

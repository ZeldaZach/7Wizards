class Price

  attr_accessor :owner, :price, :price_staff, :price_staff2, :discount_label
  
  # needed for some cases but is not required
  attr_accessor :item

  # owner is user or clan
  def initialize(owner, price, price_staff, price_staff2, item = nil)
    self.owner = owner
    self.price = price
    self.price_staff = price_staff
    self.price_staff2 = price_staff2
    self.item = item
  end

  def user
    owner.is_a?(User) ? owner : nil
  end

  def clan
    owner.is_a?(Clan) ? owner : nil
  end

  # owner can pay this price
  def acceptable?
    is_money? || is_staff2? || is_staff?
  end

  # in case if we have discount on this price label will show that
  def discount?
    !discount_label.nil?
  end

  # price can be payed by money
  def has_money_price?
    self.price && self.price > 0
  end

  # owner will spend money to pay this price
  def is_money?
    has_money_price? && self.owner.a_money >= self.price
  end

  # price can be payed by staff
  def has_staff_price?
    self.price_staff && self.price_staff > 0
  end

  # owner will spend staff to pay this price
  def is_staff?
    !self.is_staff2? && has_staff_price? && self.owner.a_staff >= self.price_staff
  end

  # price can be payed by staff2
  def has_staff2_price?
    self.price_staff2 && self.price_staff2 > 0
  end

  # owner will spend staff2 to pay this price
  def is_staff2?
    !self.is_money? && has_staff2_price? && self.owner.a_staff2 >= self.price_staff2
  end

  # first we are trying to spend money, then staff2 and then staff
  def pay(pay_all = false, description = "shop_items")
    key = self.item.is_a?(String) ? self.item : self.item.key

    if pay_all
      self.owner.spend_money(self.price, key, "#{description}.#{key}") if is_money?
      self.owner.spend_staff(self.price_staff, key, "#{description}.#{key}") if is_staff?
      self.owner.spend_staff2(self.price_staff2, key, "#{description}.#{key}") if is_staff2?
    else
      if is_money?
        self.owner.spend_money(self.price, key, "#{description}.#{key}")
      else
        if is_staff2?
          self.owner.spend_staff2(self.price_staff2, key, "#{description}.#{key}")
        else
          if is_staff?

            self.owner.spend_staff(self.price_staff, key, "#{description}.#{key}")
          else
            return false
          end
        end
      end
    end
    true
  end

  # we'll add all prices to owner
  def sell
    key = self.item.is_a?(String) ? self.item : self.item.key
    
    if has_money_price?
      self.owner.add_money(self.price, self.item.key, "shop_items.#{key}")
    elsif has_staff_price?
      self.owner.add_staff(self.price_staff, self.item.key, "shop_items.#{key}")
    elsif has_staff2_price?
      self.owner.add_staff2(self.price_staff2, self.item.key, "shop_items.#{key}")
    end
  end

end

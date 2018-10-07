class AbstractGameItem

  include Helpers::TranslateHelper

  def key
    self.class.key
  end

  def self.key
    self::KEY
  end

  def self.instance
    AllGameItems.get key
  end

  def get_price(user)
    Price.new user, 0, 0, 0, self
  end

  def is_active?(user)
    has_item?(user)
  end

  def has_item?(user)
    false
  end

  def apply(user)
    # should apply item attributes on user
  end

  def can_extend?(user)
    # you can override, should return rule
    r = Rule.new
    p = get_price(user)

    if !p.acceptable?
      if p.has_money_price?
        r.message = tr(:cant_extend_not_enought_money_on_this_item)
      elsif p.has_staff_price?
        r.message = tr(:cant_extend_not_enought_staff_on_this_item)
      else
        r.message = tr(:cant_extend_not_enought_staff2_on_this_item)
      end
    end
    r
  end

  def extend(user)
    # it's needed to override this method
  end

  def renderer
    # should return name of partial what will render item in list
  end

  def t(key, options = {})
    translate "other.game_items.#{key}", options
  end

  def tr(local_key, options = {})
    translate "rules.game_items.#{local_key}", options
  end

  def title(user = nil)
    t title_translate_key
  end

  def description(user = nil)
    t description_translate_key
  end

  def price_title(user)
    t price_translate_key, :price => tp(get_price(user).price)
  end

  def price_staff_title(user)
    t price_staff_translate_key, :price_staff => tps(get_price(user).price_staff)
  end

  protected

  def check_price(user)
    p = get_price(user)
    p.acceptable?
  end

  def attribute_name
    self.class.attribute_name
  end

  def self.attribute_name
    # override
  end

  def title_translate_key
    "#{key}.title"
  end

  def description_translate_key
    "#{key}.description"
  end

  def price_translate_key
    "price"
  end

  def price_staff_translate_key
    "price_staff"
  end

end

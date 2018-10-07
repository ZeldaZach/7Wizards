class AbstractGameTimeItem < AbstractGameItem

  attr_reader :config, :time, :price, :price_staff

  def initialize(conf = nil)
    super()
    conf_const_name = self.class.name.underscore.upcase + "_CONFIG"
    @config = conf || GameProperties.const_get(conf_const_name)
    @price = @config[:price] || 0
    @price_staff = @config[:price_staff] || 0
    @time = @config[:time] || 1.day
  end

  # override
  def has_item?(user)
    !get_expire_date(user).nil?
  end

  def get_expire_date(user)
    self.class.get_expire_date(user)
  end

  def self.get_expire_date(user)
    value = user[attribute_name]
    value.nil? || value < Time.now ? nil : value
  end

  # override
  def get_price(user)
    r = super(user)
    r.price = @price
    r.price_staff = @price_staff
    r
  end

  def extend(user, duration = nil)
    price = get_price(user)
    price.pay(false, "shop_time_items")
    
    value = get_expire_date(user) || Time.new
    value += duration ? duration : @time
    user[attribute_name] = value
  end

  #  def log_description(user)
  #    value = get_expire_date(user)
  #    "house time item: #{key}, expiration: #{value}"
  #  end

  def renderer
    'game_time_item'
  end

  def category_title
    tf AbstractGameTimeItem, "powerups"
  end

  protected

  # override
  def self.attribute_name
    "g_#{key}_expired_at"
  end

end

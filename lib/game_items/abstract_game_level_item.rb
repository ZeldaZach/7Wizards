class AbstractGameLevelItem < AbstractGameItem

  def initialize(scale = nil)
    super()
    scale_const_name = self.class.name.underscore.upcase + "_SCALE"
    scale = scale || GameProperties.const_get(scale_const_name)
    @scale = []
    if scale
      scale.each do |item|
        parse_scale_item @scale, item
      end
    end
  end
  
  # override
  def can_extend?(user)
    r = super(user)
    if r.allow?
      level = get_level(user)
      if level >= get_max_level
        r.message = tr(:cant_extend_reach_max_level)
      end
    end
    r
  end

  # override
  def extend(user)
    p = get_price(user)
    p.pay
    
    level = get_level(user) + 1
    user[attribute_name] = level
  end

  # override
  def has_item?(user)
    get_level(user) > 0
  end

  def get_level(user)
    user[attribute_name] || 0
  end

  def get_max_level
    @scale.length - 1
  end

  # override
  def get_price(user)
    l = get_level(user)
    p = get_level_price(l)
    r = super(user)
    r.price = p[:price]
    r.price_staff = p[:price_staff]
    r
  end

  def get_level_price(level)
    i = get_level_scale_item(level)
    {
      :price => i[:price] || 0,
      :price_staff => i[:price_staff] || 0
    }
  end

#  def log_description(user)
#    level = get_level(user)
#    "extend house level item: #{key}, level: #{level}"
#  end

  def level_description(level)
    i = get_level_scale_item(level)
    level_scale_item_description(i)
  end

  def current_level_description(user)
    l = get_level(user)
    t :current_level, :value => level_description(l)
  end

  def next_level_description(user)
    l = get_level(user)
    if l < get_max_level
      t :next_level, :value => level_description(l + 1)
    end
  end

  def renderer
    'game_level_item'
  end

  def get_user_scale_item(user)
    l = get_level(user)
    get_level_scale_item(l)
  end

  def get_level_scale_item(level)
    @scale[level]
  end

  protected
  
  def parse_scale_item(scale, item)
#    scale << item
  end

  def level_scale_item_description(item)
    # should return description by level item
  end

  # override
  def self.attribute_name
    "g_#{key}"
  end

end

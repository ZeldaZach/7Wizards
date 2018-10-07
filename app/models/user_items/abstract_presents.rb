class UserItems::AbstractPresents < UserItems::AbstractShopUserItem
  include Helpers::TranslateHelper

  def apply(ua)
    self.class.apply(ua, self)
  end

  def hours
    self.class.hours
  end

  def percent
    self.class.percent
  end

  def required_level
    self.class.required_level
  end
  
  def present_name
    self.class.present_name
  end

  def description(user=nil)
    d = self.class.description(user)
    if self.active_till
      d += "#{tf(UserItems::AbstractPresents, :hours_left)}: #{(self.active_till - Time.new).seconds_to_full_time}<br />"
    end
    d
  end

  def need_replacement?
    items = get_user_used_items
    return true if items.size >= GameProperties::PRESENT_MAX
    items.each do |item|
      return true if item.key == self.key
    end
    false
  end

  def find_replacement
    items = get_user_used_items

    items.each do |item|
      if item.key == self.key
        return item
      end
    end

    res = nil
    for i in 1..recipient_level do
      items.each do |item|
        if i == item.recipient_level
          res = item if !res || res.present_reasigned_at > item.present_reasigned_at
        end
      end
    end
    res
  end

  def get_user_used_items
    self.class.get_user_used_items(self.user)
  end

  # called from controller when user try to send present
  # we can override it if we need to perform any action on present send
  def send_present
  end

  class << self

    include Helpers::FormattingHelper

    def get_user_used_items(user)
      user.send("used_#{category}s")
    end

    # should return used items with the same class
    def get_user_used_items_by_class(user)
      items = get_user_used_items(user)
      items.select do |item|
        item.class == self
      end
    end

    # used for custom apply operations, return percent as number 1..100
    def get_custom_percent(user)
      items = get_user_used_items_by_class(user)
      percent = 0
      items.each { |item| percent += item.percent }
      percent
    end

    # used for custom apply operations
    def get_custom_percent_apply_diff(user, value)
      percent = get_custom_percent(user)
      percent != 0 ? (value * percent.to_percent).to_i : 0
    end

    # used for custom apply operations
    def apply_custom_percent(user, value)
      value += get_custom_percent_apply_diff(user, value)
    end

    # used for custom apply operations
    # only works for custom presents, presents with custom classes
    def is_custom_active?(user)
      items = get_user_used_items_by_class(user)
      items.length > 0
    end

    # used for custom apply operations
    # only works for custom presents, presents with custom classes
    def is_custom_fired?(user)
      percent = get_custom_percent(user)
      percent > 0 && rand <= percent.to_percent
    end

    # override
    def can_buy?(user)
      r = Rule.new

      if !check_price user
        r.message = tr(:cant_buy_not_enought_money_on_this_item)
        return r
      end

      if required_level > user.a_level
        r.message = tr(:level_too_small)
        return r
      end

      r
    end

    # override
    def can_use?(user, options = {})
      r = Rule.new
      r.message = tr(:cant_use_present)
      r
    end

    # override
    def can_sell?(user)
      r = Rule.new
      r.message = tr(:cant_sell_present)
      r
    end

    def user_attribute_value(name)
      name = "@config_#{name}"
      instance_variable_defined?(name) ? instance_variable_get(name) : 0
    end

    def user_attribute_percent_value(name)
      name = "@config_#{name}_percent"
      instance_variable_defined?(name) ? instance_variable_get(name) : 0
    end

    # custom item description defined in YML file
    def item_description
      @config_description || ''
    end

    # override
    def description(user = nil)
      r = item_description
      
      if r.blank?
        param_value = proc { |name|          
          value = user_attribute_value(name)
          if value != 0
            "#{tf(UserItems::AbstractPresents, name.to_sym)}: #{np(value)}<br />"
          else
            value = user_attribute_percent_value(name)
            if value != 0
              "#{tf(UserItems::AbstractPresents, name.to_sym)}: #{np(value)}%<br />"
            else
              ''
            end
          end
        }

        r = param_value.call :power
        r += param_value.call :protection
        r += param_value.call :dexterity
        r += param_value.call :skill
        r += param_value.call :weight
      else
        r = "#{r}<br />"
      end

      r += "#{tf(UserItems::AbstractPresents, :hours)}: #{tg(:hours, :count => @config_hours)}<br />" if @config_hours
      r
    end

    def apply(ua, item)
      apply_attribute = proc do |name|
        attr = "#{category}s_#{name}"
        attr_value = ua.send(attr) || 0

        value = user_attribute_value(name)
        if value != 0
          attr_value += value
          ua.send("#{attr}=", attr_value.to_i)
        else
          percent = user_attribute_percent_value(name)
          if percent != 0
            value = ua.send("a_#{name}")
            attr_value += percent.to_percent * value
            ua.send("#{attr}=", attr_value.to_i)
          end
        end
      end

      apply_attribute.call :protection
      apply_attribute.call :power
      apply_attribute.call :dexterity
      apply_attribute.call :skill
      apply_attribute.call :weight
    end

    def add(user, multi = true)
      super
    end

    # override
    def image_url
      "/images/gifts/#{key}.jpg"
    end

    def hours
      @config_hours
    end

    def percent
      @config_percent
    end

    def required_level
      @config_level
    end

    def present_name
      @config_name
    end

  end
end

class UserAvatar < ActiveRecord::Base

  DEFAULT_BODY_COLOR = 15451050
  
  include BaseModel
  
  belongs_to :user

  serialize :clothes, Hash

  named_scope :by_key, lambda  { |key| { :conditions => {:key => key } } }

  def required_level
    self.class.required_level
  end

  def price_staff
    self.class.price_staff
  end

  def available_clothes
    self.class.available_clothes
  end

  class << self

    def key
      @config_key
    end
    
    def get_price(user)
      Price.new user, price, price_staff, 0, self
    end

    def price_staff
      @config_price_staff
    end

    def price
      @config_price
    end

    def required_level
      @config_level
    end

    def available_clothes
      @config_clothes
    end

    def clothes
      default_used_clothes
    end

    def body_color
      @body_color || DEFAULT_BODY_COLOR
    end

    def body_color=(v)
      @body_color = v
    end

    #default - mean default avatar, not need spend money and validate
    def buy(user, default = false)
      item = add(user, default)
      if item
        price = get_price(user)
        if default || price.pay(false, "avatar_items")
          user.active_avatar = item
          return item
        end
      end
      nil
    end
    def buy!(user, default = false)
      if buy(user, default)
        user.save!
      end
    end

    def add(user, default = false)
      if default || !has?(user)
        a = new_item_instance
        user.user_avatars << a
        return a
      end
      nil
    end

    def has?(user)
      !get(user).nil?
    end

    def get(user)
      user.user_avatars.by_key(key).first
    end

    #  # by default you can have only one item and buy == extend
    # if you need to allow to have more items you should override this method
    def can_buy?(user)
      r = Rule.new

      if has? user
        r.message = UserAvatar.tr(:cant_buy_you_already_have_this_avatar)
        return r
      end

      if !check_price user
        r.message = UserAvatar.tr(:cant_buy_not_enought_money_on_this_avatar)
        return r
      end

      if user.a_level < required_level.to_i
        r.message = UserAvatar.tr(:cant_buy_required_level, :level => required_level)
        return r
      end

      r
    end

    protected

    def new_item_instance
      a = self.new
      a.key = self.key
      a.clothes = self.default_used_clothes
      a.body_color = DEFAULT_BODY_COLOR
      a
    end

    def check_price(user)
      p = get_price(user)
      p.acceptable?
    end
  end

end

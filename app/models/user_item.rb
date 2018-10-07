class UserItem < ActiveRecord::Base

  include BaseModel

  belongs_to :user
  belongs_to :bought_by,
    :class_name => 'User',
    :foreign_key => 'bought_by_id'

  named_scope :all_reasigned, lambda  { |category|
    {
      :conditions => ["category = ? and reasigned_at is not null", category]
    }
  }

  named_scope :shop_items, lambda{ | user |{ :conditions => ["user_id = ? AND reasigned_at is null AND category in (?) ", user.id,  AllUserItems.categories.collect {|k| k = k.to_s}]}}
  named_scope :sent_gifts_to_user, lambda{ | user |{ :conditions => ["reasigned_at is not null and (user_id = ? OR user_id = ?)", user.id, -user.id] }}

  # override
  def initialize
    super
    
    # we need to populate DB field
    self.category = self.class.category
  end

  def title
    self.class.title
  end

  def description(user=nil)
    self.class.description(user)
  end

  def category
    self.class.category
  end

  def category_title
    self.class.category_title
  end

  def takeoff(user)
    self.class.takeoff(user)
  end

  # it's soft delete
  def deactivate!
    if self.user_id > 0
      self.user_id = -self.user_id
      self.in_use = false if self.in_use
      self.save!
    end
  end

  def image_url
    self.class.image_url
  end

  class << self

    #override
    def new
      r = super
      r.key = key
      r
    end

    def key
      @config_key
    end

    def title
      @config_name
    end

    def description(user=nil)
      @config_description
    end

    def category
      @config_category
    end

    def category_label
      tf UserItem, "category_#{category}"
    end

    def category_title
      "#{self.category_label} - #{self.title}"
    end

    def image_url
      "/images/items/#{key}.gif"
    end

    def required_level
      @config_level
    end

    def get_price(user)
      Price.new user, @config_price, @config_price_staff, @config_price_staff2, self
    end

    def get_sell_price(user)
      Price.new user, @config_sell_price, 0, 0, self
    end

    def has?(user)
      !get(user).nil?
    end

    def get(user)
      user.get_item_by_key self.key
    end

    def add(user, multi = false)
      if !has?(user) || multi
        item = new_item_instance user
        item.bought_by = user
        user.items << item
        return item
      end
      nil
    end

    # by default you can have only one item and buy == extend
    # if you need to allow to have more items you should override this method
    def can_buy?(user)
      r = Rule.new

      if has? user
        r.message = tr(:cant_buy_you_already_have_this_item)
        return r
      end

      if !check_price user
        p = get_price(user)
        if p.has_money_price?
          r.message = tr(:cant_buy_not_enought_money_on_this_item)
        elsif p.has_staff2_price?
          r.message = tr(:cant_buy_not_enought_staff2_on_this_item)
        else
          r.message = tr(:cant_buy_not_enought_staff_on_this_item)
        end
        return r
      end

      r
    end

    def buy(user)
      item = add user
      if item
        price = get_price(user)
        if price.pay
          return item
        end
      end
      nil
    end

    def can_sell?(user)
      r = Rule.new

      item = get(user)
      unless item
        r.message = tr(:you_dont_have_it_to_sell)
        return r
      end
      
      if item.in_use
        r.message = tr(:you_cant_sell_used_item)
        return r
      end

      unless get_sell_price(user).has_money_price?
        r.message = tr(:you_can_earn_only_money_on_sell)
        return r
      end

      r
    end

    #do we need show button BUY
    #override
    def button_buy?(user = nil)
      true
    end

    #do we need show button EXTEND
    #override
    def button_extend?(user = nil)
      false
    end

    def sell(user)
      item = get user
      if item
        price = get_sell_price(user)
        price.sell
        user.items -= [item]
        return item
      end
      nil
    end

    def can_use?(user, options = {})
      r = Rule.new

      item = get(user)
      if !item
        r.message = tr :you_should_have_item_to_use
        return r
      end

      if item.in_use
        r.message = tr :item_is_already_used
        return r
      end

      if user.a_level < self.required_level
        r.message = tr :level_too_small, :level => self.required_level
        return r
      end

      r
    end

    def use(user, options = {})
      item = get user
      if item
        item.in_use = true
      end
      item
    end

    def use!(user, options = {})
      i = use(user, options)
      i.save! if i
    end

    def can_takeoff?(user)
      r = Rule.new

      item = user.get_item_by_key self.key
      if !item
        r.message = tr :you_should_have_item_to_takeoff
        return r
      end

      if !item.in_use
        r.message = tr :you_should_use_item_to_takeoff
        return r
      end

      r
    end

    def takeoff(user)
      item = get user
      if item
        item.in_use = false
      end
      item
    end

    # class methods here
    def t(local_key, options = {})
      translate_key = "models.user_items.#{self.key}.#{local_key}"
      translate translate_key, options
    end

    # class methods here
    def tr(local_key, options = {})
      translate_key = "rules.user_items.#{local_key}"
      translate translate_key, options
    end

    def get_used_from_category(user)
      nil
    end

    protected

    def new_item_instance(user)
      self.new
    end

    def check_price(user)
      p = get_price(user)
      p.acceptable?
    end
    
  end
end

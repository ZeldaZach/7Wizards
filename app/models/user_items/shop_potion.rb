class UserItems::ShopPotion < UserItems::AbstractShopUserItem

  CATEGORY = :potion

  class << self

    # override
    def can_use?(user, options = {})
      r = super(user, options)
      return r if !r.allow?

      last_used = user.e_get_last_potion_usage(self.key)

      if self.for_pet?
        if !user.pet_is_live?
          r.message = tr(:potion_no_pet)
          return r
        end
        if last_used && last_used > self.time_between_usage.ago
          r.message = tr(:potion_pet_usage_time_restriction,
            :minutes => self.time_between_usage.seconds_to_minutes,
            :remain => (last_used - self.time_between_usage.ago).seconds_to_time
          )
          return r
        end
        if user.pet_health >= user.max_pet_health
          r.message = tr(:potion_pet_usage_max_health_reached)
          return r
        end
      else
        if last_used && last_used > self.time_between_usage.ago
          r.message = tr(:e_potion_usage_time_restriction,
            :minutes => self.time_between_usage.seconds_to_minutes,
            :remain => (last_used - self.time_between_usage.ago).seconds_to_time
          )
          return r
        end

        if user.a_health >= user.max_health && !is_mana?
          r.message = tr(:e_potion_usage_max_health_reached)
          return r
        end
      end

      return r
    end

    def can_buy?(user)
      r = Rule.new

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

    # override
    def use(user, options = {})
      item = get user
      if item
        apply_potion user, options
        item.deactivate!
        user.e_use_potion! item.key
      end
    end

    def add(user, multi = true)
      super(user, multi)
    end
    
    protected

    def is_mana?
      !@config_mana.nil?
    end

    def time_between_usage
      @config_minutes ? @config_minutes.minutes : 0
    end

    # will apply potion attributes on user
    def apply_potion(user, options = {})
      if is_mana?
        add_user_mana user
      elsif self.for_pet?
        apply_user_pet_health user
      else
        apply_user_health user
      end
    end
    
    # you can override if needed
    def apply_user_health(user)
      if @config_health_percent
        user.a_health = user.max_health
      else
        user.a_health += @config_health
        user.a_health = user.max_health if user.a_health > user.max_health
      end
    end

    # you can override if needed
    def apply_user_pet_health(user)
      if @config_health_percent
        user.pet_health = user.max_health
      else
        user.pet_health += @config_health
        user.pet_health = user.max_pet_health if user.pet_health > user.max_pet_health
      end
    end

    def add_user_mana(user)
      user.add_money!(@config_mana, self.key, "potion.#{self.key}")
    end
  end

end

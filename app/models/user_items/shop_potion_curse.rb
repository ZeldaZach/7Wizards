class UserItems::ShopPotionCurse < UserItems::ShopPotion

  class << self

    def cancel_all
      false
    end

    # will return curse potion for user if he has any
    def get_user_potion(user)
      potion = nil
      user.available_items.each do |item|
        if item.class == self && ((cancel_all && item.class.cancel_all) || (!cancel_all && !item.class.cancel_all))
          potion = self
          break
        end
      end
      potion
    end

    # override
    def can_use?(user, options = {})
      r = Rule.new

      if self.for_pet?
        r.message = tg(:strange_situation)
        return r
      end

      last_used = user.e_get_last_potion_usage(self.key)

      if last_used && last_used > self.time_between_usage.ago
        r.message = tr(:e_potion_usage_time_restriction,
          :minutes => self.time_between_usage.seconds_to_minutes,
          :remain => (last_used - self.time_between_usage.ago).seconds_to_time
        )
        return r
      end

      unless cancel_all
        curse = options[:curse]

        # in case when we want to cancel one curse it should be present in options
        unless curse
          r.message = tr(:potion_curse_cancel_no_curse)
          return r
        end

        if curse.user != user || !curse.in_use
          r.message = tg(:strange_situation)
          return r
        end
      end

      if user.used_curses.empty?
        r.message = tr(:potion_no_used_curses)
        return r
      end

      r
    end

    protected

    # override
    def apply_potion(user, options = {})
      if cancel_all
        user.used_curses.each do |curse|
          curse.deactivate!
        end

        Message.create_present_potion_usage(user)
      else
        curse = options[:curse]
        curse.deactivate!

        Message.create_present_potion_usage(user, curse)
      end
    end
  end

end

module ClanExt
  module Stats

    # amount of approved join requests in current month
    def s_month_joins
      last_join = get_stat_value :lm_join, nil # last month join
      last_join = nil if last_join && Time.now.beginning_of_month > last_join # reset counter if it was previous month

      # in case if last join was in previous month we reset counter
      last_join ? get_stat_value(:m_joins, 0) : 0
    end

    def s_month_joins=(value)
      set_stat_value :lm_join, Time.now
      set_stat_value :m_joins, value
    end

    # we store total amount of money paid by users
    def s_get_user_payment(user)
      payments = get_stat_value :payments, {}
      r = payments[user.id] || {}
      r[:money] = 0 if r[:money].nil?
      r[:staff] = 0 if r[:staff].nil?
      r[:staff2] = 0 if r[:staff2].nil?
      r
    end

    def s_add_user_payment(price)
      value = s_get_user_payment price.user
      value[:money] += price.price
      value[:staff] += price.price_staff
      value[:staff2] += price.price_staff2

      payments = get_stat_value :payments, {}
      payments[price.user.id] = value
      set_stat_value :payments, payments
    end

    def s_reset_users_payments
      set_stat_value :payments, nil
    end

  end
end

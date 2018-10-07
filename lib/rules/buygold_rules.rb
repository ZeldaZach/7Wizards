class BuygoldRules < AbstractRules
  def self.can_buy(user)
    r = Rule.new
    if !user.confirmed_email
      r.message = tg(:account_not_activated)
      return r
    end
    r
  end
end

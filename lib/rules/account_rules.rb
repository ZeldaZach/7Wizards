class AccountRules < AbstractRules
  
  def self.can_activate(user, recaptcha)
    r = Rule.new

    if !recaptcha
      r.message = te(:captcha_error)
      return r
    end

    if user.unsubscribe
      r.message = t(:account_unsubscribed)
      return r
    end
    r
  end

  def self.can_restore_password(user)
    r = Rule.new

    if user.nil?
      r.message = t(:email_or_login_not_valid)
      return r
    end

    if user.unsubscribe
      r.message = t(:account_unsubscribed)
      return r
    end
    r
  end
  
end

module VisitorExt
  module ChangePassword

    def restore
    end

    def restore_do
      name  = params[:name]
      email = params[:email]

      if !name.blank? && !email.blank?
        user = User.find_by_name_and_email(name.capitalize, email)
      end

      r = AccountRules.can_restore_password(user)

      if r.allow?
        Notifier.deliver_restore_password(user)
        flash[:notice] = t(:check_you_email)
      else
        flash[:notice] = r.message
      end
      render :action => :restore
    end

    def change_password
      @hash = params[:rh]

      id = RedisCache.get(@hash) unless @hash.blank?
      user = User.find_by_id(id)
      if user.nil?
        redirect_to_with_notice t(:incorrect_url_data), login_url
      end
    end

    def do_change_password
      @hash = params[:rh]

      if @hash.blank?
        redirect_to_with_notice t(:incorrect_url_data), login_url
        return
      end
      
      id = RedisCache.get(@hash)

      user = User.find_by_id(id)
      user.password = params[:password]
      user.password_confirmation = params[:confirm_password]

      if user.valid_with_password?(true)
        user.e_restore_password_hash = nil
        user.save!
        login_user(user)
        redirect_to root_url
      else
        redirect_to_with_notice user.errors.on(:password), visitor_path(:action => :change_password, :rh => @hash, :id => id)
      end
    end

  end
end

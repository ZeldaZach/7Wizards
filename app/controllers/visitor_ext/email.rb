module VisitorExt
  module Email

    def confirm_mail
      hash = params[:ch]

      id = RedisCache.get hash if !hash.blank?

      unless id.blank?
        user = User.find_by_id(id)

        if user
          user.confirmed_email = true
          user.save!
          return if login_user(user, false, home_url(:action => :index, :callback => "/confirm_email/success"), t(:your_accout_activated))
        end

      end
      redirect_to_with_notice t(:confirmation_not_valid), login_url
    end
  
    #seem user registered with incorrect email
    def bounce_hook
      email = params[:Email]
      user  = User.find_by_email(email)
      user.update_attributes!(:bounced_email => true) if user
      render :nothing => true
    end

    def unsubscribe
      email_md5 = params[:uh]
      user = User.find_md5_email(email_md5)
      if user
        user.unsubscribe = true
        user.save!
        message = t(:unsubscribed)
      else
        message = t(:incorrect_url_data)
      end
      do_logout
      redirect_to_with_notice message, login_url
    end
    
  end
end

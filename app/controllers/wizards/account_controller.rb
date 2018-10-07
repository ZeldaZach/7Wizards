class Wizards::AccountController < WizardsController
  
  def change_password
    @user = current_user
    render_popup :title => t(:change_passwotd_title)
  end

  def do_change_password
    @user_password = params[:password]
    user_params    = params[:user]

    @user = current_user

		u = User.authenticate(@user.name, @user_password)
    if !u
      flash[:notice] = te(:invalid_password)
    else
      u.password = user_params[:password]
      u.password_confirmation = user_params[:password_confirmation]
      if u.valid_with_password?(true)
        u.save!

        Notifier.deliver_send_user_password(u, user_params[:password])
        @changed = true
      else
        flash[:notice] = u.errors.on(:password)
      end
    end
    
    render_popup :title => t(:change_passwotd_title), :partial => "change_password"
  end

  def do_delete_account
    respond_to do |format|
      format.js do
        
        @user = current_user
        @user.active = false
        @user.deleted = true
        @user.save!

        reset_session
        render :update do |p|
          p.reload
        end and return false
      end
    end
  end

  def activate_account
    @user = current_user
    cookies[:cd] = 'false'
    render_popup :title => t(:activate_account_title)
  end

  def do_sent_confirmation
    @user = current_user

    r = AccountRules.can_activate(@user, verify_recaptcha)
    if r.allow?
      Notifier.deliver_confirm_registration(@user)
      render :update do |page|
        page.call_fn "dialog.close()"
      end
    else
      redirect_to_with_notice r, account_path(:action => :activate_account)
    end
  end
end

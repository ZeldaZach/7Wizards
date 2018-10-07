class VisitorController < ApplicationController

  layout 'visitor'

  include VisitorExt::Email
  include VisitorExt::ChangePassword
  include VisitorExt::Profile

  before_filter :visitor_filter, :only => [:index, :reference_register, :process_login, :process_register]

  def index

    if logged_in?

      if admin?
        redirect_to :controller => 'admin'
      else
        redirect_to home_url
      end
    else

      if bigpoint_host?
        redirect_to :controller => 'bigpoint'
        return
      end

      @user = User.new
    end
  end

  def reference_register
    index
    return if logged_in?
    @referral_name = params[:name]
    render :index
  end

  def process_login
    @user_name = params[:login]
    @user_password = params[:password]

		user = User.authenticate(@user_name, @user_password) if !@user_password.blank? && !@user_name.blank?

    if user && !user.admin?
      if !login_user(user, !params[:remember_me].blank?)
        redirect_to :action => :na, :id => user.id
      end
    else
      @user = User.new
      flash[:notice] = t(:problems_with_login)
      render :index
    end
  end

  def process_register
    @user = User.new
    @referral_name = params[:referral_name]
    @user.referral = User.f @referral_name unless @referral_name.blank?

    u = params[:user]
    if u
      @user.name     = u[:name].separate_upper
      @user.gender   = u[:gender]
      @user.email    = u[:email]
      @user.password = u[:password]
      @user.password_confirmation = u[:password_confirmation]
      @user.register
    end
    
    if !@user.valid_with_password?(true) #|| !verify_recaptcha(:model => @user, :message => te(:captcha_error))
      render :index
      return
    end


    if @user.referral
      r = Relation.new
      r.user = @user
      r.relative = @user.referral
      r.message = User.t(:relation_message_friend_referral, :name => @user.name)
      r.request_message = User.t(:relation_request_message_friend_referral, :name => @user.name)
      r.kind = Relation::KIND_FRIEND
      r.active = false
    end
    
    saved = false
    @user.transaction do
      avatar = AllUserAvatars.get_default_avatar(@user)
      avatar.buy(@user, true)
      saved = @user.save # TODO very strange code ... seems should be save!
                         # Not need validate record twice, see above, @user.valid_with_password?(true)
                         
      if saved && !r.nil?
        r.save!
      end
    end
    
    if saved
      user_info = UserMarketingInfo.create_user_info(@user, cookies)
      user_info.adjust
      
      Notifier.deliver_confirm_registration(@user)
      
      if !login_user(@user, false, home_url(:action => :index, :callback => "/register/success"))
        redirect_to home_url
      end
    else
      render :index
    end
  end

  # it can be used for banned or users on holiday
  def na
    @user = params[:id] ? User.find(params[:id]) : current_user
    if @user
      if !@user.active
        @ban = @user.active_ban
        render :na_active
        return
      end
      if @user.holiday_is_active?
        render :na_holiday
        return
      end
    end
    redirect_to_login
  end

  def preview
    render_popup :partial => "preview", :layout => false
  end
  
  private

  def login_user(user, remember_me = false, url = home_path, notice = '')
    # we should adjust user attributes here
    user.adjust_attributes true, false
    return false if user.holiday_is_active? || !user.active?
    
    session[:user] = user.id

    if remember_me
      user.remember_me!
      cookies[:remember_token] = {
        :value   => user.remember_token,
        :expires => 1.years.from_now.utc
      }
    end

    # reset on holiday flag
    user.on_holiday = false

    # we should register user login activity

    #on login not need validate password
    user.register_activity! 'login', false

    redirect_to_with_notice notice, url

    true
  end

  def visitor_filter
    @top_users = User.find_the_best_top10
  end

end

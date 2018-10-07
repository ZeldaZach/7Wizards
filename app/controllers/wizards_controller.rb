class WizardsController < ApplicationController

  require 'json'

  before_filter :authorize_access, :except => ['logout']
  before_filter :flash_vars

  #DEFAULT render_content for all actions
  def default_render #:nodoc:
    begin
      render_content
    rescue ActionView::MissingTemplate => e
      # Was the implicit template missing, or was it another template?
      if e.path.gsub('/_', '/') == default_template_name
        raise ActionController::UnknownAction, "No action responded to #{action_name}. Actions: #{action_methods.sort.to_sentence(:locale => :en)}", caller
      else
        raise e
      end
    end
  end
  
  def authorize_access
    if !logged_in?

      redirect_to_login t(:login_is_needed)
    else
      user = current_user
      if user.is_admin
        redirect_to :controller => 'admin'
      else
        if !user.active
          do_logout
          redirect_to(:controller => 'visitor', :action => 'na')
        else
          if user.on_holiday?
            logout_internal
          end
        end
      end
    end
  end

  def confirm
  end

  def index
    render_content
    #redirect_to home_url
  end

  def reload_user_info
    render :update do |page|
      page.replace_html :user_info, render("navigation/user_info")
    end
  end

  def confirm_dialog
    @confirmation         = CGI::unescape(params[:confirmation]) unless params[:confirmation].blank?
    @confirm_url          = CGI::unescape(params[:confirm_url]) unless params[:confirm_url].blank?
    @dialog_callback_url  = params[:callback]
    render_popup :title => t(:confirmation_title)
  end

  def history_back
    redirect_to pop_history
  end

  def change_email
    @user = current_user
    render_popup
  end

  def do_change_email
    email = params[:email]
    @user = current_user

    r = ProfileRules.can_change_email(@user, email)

    if r.allow?
      @user.bounced_email = false
      @user.email = email
      @user.save!

      Notifier.deliver_confirm_registration(@user)
      @dialog_close = true
    else
      flash[:notice] = r.message
    end
    redirect_to home_path(:action => :index_ajax)
  end

  #for new user, welcom pop up
  def welcom
    cookies[:cd] = 'false'
    render_popup :title => t(:welcom_title)
  end

  def accept_welcom
    redirect_to home_path(:action => :start_tutorial)
  end

  def cancel_welcom
    Message.send_guru_message(current_user)
    redirect_to home_path(:action => :cancel_tutorial)
  end

  def navigate_menu_task
    user = current_user
    user.done_task!(TutorialNavigation::NAME)
    render :nothing => true
  end

  def achivement_notify
    @achivement = current_user.get_last_achivement
    if @achivement.nil?
      redirect_to :action => :accept_achivement
    else
      render_popup :title => t(:achivement_title)
    end
  end

  def accept_achivement
    AbstractAchivement.accept_notification(current_user)
    render :nothing => true
  end

  def change_name
    @user = current_user

    if @user.facebook?
      @name = @user.fb_name
    elsif @user.hi5?
      @name = @user.hi5_name
    end
    return if @user.confirmed_email
    render_popup :title => tg(:app_title)
  end

  #for hi5 and facebook users
  def do_change_name
    @user = current_user

    if @user.confirmed_email
      redirect_to home_url
      return
    end

    @user.name = params[:name].separate_upper
    @user.gender = params[:user][:gender]

    if @user.valid?
      @user.transaction do
        @user.confirmed_email = true
        avatar = AllUserAvatars.get_default_avatar(@user)
        avatar.buy(@user, true)
        @user.save!
      end

      redirect_to wizards_path(:action => :welcom)
    else
      redirect_to_with_notice @user.errors.full_messages.first, wizards_path(:action => :change_name)
    end
  end

  def hi5_publish_achivement
    user = current_user
    @achivement = user.get_last_achivement
    title = t(:achivement_publish_reached_new_level, :level => @achivement.get_level(user), :title => @achivement.title)
    hi5_publish(fbsession, t(:achivement_title), title, @achivement.image_url)
    redirect_to wizards_path(:action => :accept_achivement)
  end

  def facebook_publish
    user = current_user
    @achivement = user.get_last_achivement
    title = t(:achivement_publish_reached_new_level, :level => @achivement.get_level(user), :title => @achivement.title)
    facebook_connect_publish(title, @achivement.image_url)
    redirect_to wizards_path(:action => :accept_achivement)
  end

  protected

  def flash_params
    @flash_params
  end

  private

  def flash_vars
    json = params[:json]
    @flash_params = json.blank? ? {} : JSON.parse(json)
  end

end

class BigpointController < ApplicationController
  layout 'visitor'

  require "xmlrpc/server"
  require "xmlrpc/create"
  
  before_filter :bigpoint_filter, :only => [:index]

  def xmlrpc
    service = Services::BigpointService::Game.new request

    user = service.get_user_and_adjust
    
    unless user.nil?
      acts = Services::BigpointService::Game::ACTIONS
      result = {}

      if service.method_name == acts[:login] ||
          service.method_name == acts[:register]

        result[:result] = "OK"
        
        result[:userID] = user.id
        result[:bpUserID] = user.bp_user_id
        
        if login_user(user)
          result[:redirectURL] = "#{BigpointConfig.host}/?authToken=#{user.remember_token}"
        else
          result[:redirectURL] = "#{BigpointConfig.host}#{visitor_path(:action => :na, :id => user.id)}"
        end
        
      elsif service.method_name == acts[:delete] ||
          service.method_name == acts[:block]  ||
          service.method_name == acts[:book_item]

        result[:result] = "OK"

      elsif service.method_name == acts[:stats]

        result[:result] = "OK"
        result[:virtualCurrency] = 0
        result[:realCurrency] = user.a_staff
        result[:userRank] = user.a_level
        
      elsif service.method_name == acts[:get_lang]
        result[:result] = "OK"
        result[:projectID] = BigpointConfig.project_id
        result[:userID] = user.id
        
      else
        render_error("Action not registered")
        return
      end
      render_responce(result)
      return
    else
      render_error("Error: user not found")
    end
    
  end

  def index
    
    if logged_in?
      if admin?
        redirect_to :controller => 'admin'
      else
        redirect_to home_url
      end
    elsif !bigpoint_host?
      redirect_to :controller => 'visitor'
      #TODO
    else
      redirect_to BigpointConfig.login_url
    end
#    @iframe_service = Services::BigpointService::IFrame.new
  end

  def bigpoint_confirm
    @user = current_user

    unless @user
      redirect_to(:action => 'index')
      return
    end

    render_popup :title => tg(:app_title)
  end

  def do_bigpoint_confirm
    @user = current_user
    
    if @user.nil? || (@user && @user.confirmed_email)
      redirect_to home_url
      return
    end

    u = params[:user]
    if u
      @user.name     = params[:name].separate_upper
      @user.gender   = u[:gender]
      @user.confirmed_email = true

      if @user.valid?
        @user.transaction do
          avatar = AllUserAvatars.get_default_avatar(@user)
          avatar.buy(@user, true)
          @user.save!
        end
        redirect_to wizards_path(:action => :welcom)
      else
        redirect_to_with_notice @user.errors.full_messages.first, bigpoint_path(:action => :bigpoint_confirm)
      end
    end
  end

  def login_user(user)
    user.adjust_attributes true, false
    return false if user.holiday_is_active? || !user.active?
    
    session[:user] = user.id

    user.remember_me!
    user.register_activity! 'login', false
    
    return true
  end

  def reference_register
    index
    return if logged_in?
    @referral_name = params[:name]
    render :index
  end

  def bigpoint_filter
    @top_users = User.find_the_best_top10
  end

  def render_responce(*params)
    client = XMLRPC::Create.new
    render :text => client.methodResponse(true, *params)
  end

  def render_error(message = "INVALID_XML")
    client = XMLRPC::Create.new
    render :text => client.methodResponse(false, XMLRPC::FaultException.new(-1, message))
  end


  
end

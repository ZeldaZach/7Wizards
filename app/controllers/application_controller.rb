# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base

  unloadable # http://stackoverflow.com/questions/1242559/a-copy-of-applicationcontroller-has-been-removed-from-the-module-tree-but-is-stil

  include ExceptionNotifiable
  include EdgesoftNoCookie
  include Helpers::TranslateHelper
  include Helpers::ActionControllerLoggingExt
  include Helpers::DoubleRequestHelper
  include Helpers::Hi5Helper
  include ApplicationExt::Facebook

  #deprecated
  include ApplicationExt::History

  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => 'e70c3ce2be5e91d4571a4b8bfc41817d'
  
  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  # filter_parameter_logging :password
  

  before_filter :reload_dev_classes, :set_locale, :reset_flash_message
  before_filter :check_session

  before_filter :hi5_filter, :facebook_register

  #reset session
  sliding_session_timeout 43200

  #redirect for ajax requests
  def check_session
    return if ["visitor", "bigpoint"].include?(self.controller_name)

    respond_to do |format|
      format.html { (redirect_to(login_url) and return false) }
      format.js do
        render :update do |p|
          p.reload
        end and return false
      end
    end unless session[:user]
  end

  def hi5_filter
    return unless hi5_host?
    require_facebook_login
    session[:_hi5_ref_host] = params[:ref_host] if fbparams["user"]
    session[:hi5_user] = fbparams["user"] unless logged_in?
  end

  def facebook_register
    return if session[:user]
    
    fbc_session = get_facebook_cookie
    user_info   = facebook_user_info
    if fbc_session && user_info
      user = User.facebook_register(user_info)
      session[:user] = user.id
    end
  end

  # in debug mode we should reload some classes because we create them dinamically
  def reload_dev_classes
    if !Rails.configuration.cache_classes
      AllUserItems.reset
      AllUserAvatars.reset
    end
  end

  def set_locale
    I18n.locale = I18n.default_locale
  end

  def is_notice?
    cookies[:cn] != 'false'
  end

  def reset_flash_message
    if is_notice?
      flash[:notice] = nil
      flash[:info] = nil
    else
      cookies[:cn] = 'true'
    end
    #set close dialog automatically
    cookies[:cd] = 'true'
  end

  def redirect_to_with_notice(notice, options = {}, response_status = {})
    unless performed?
      if notice.is_a?(Hash) && notice[:info]
        flash[:info] = notice[:info] unless notice[:info].blank?
      else
        e = notice.is_a?(Rule) ? notice.message : notice.to_s
        flash[:notice] = e unless e.blank?
      end
      cookies[:cn] = 'false'
      redirect_to options, response_status
    end
  end

  # redirect only first time
  def redirect_to(options = {}, response_status = {}) #:doc:
    unless performed?
      if ajax_request?
        render :update do |page|
          page.redirect_to options
        end
      else
        super(options, response_status) 
      end
    end
  end

  # we should render only in case when redirect was not performed
  def render(options = nil, extra_options = {}, &block) #:doc:
    super(options, extra_options, &block) unless performed?
  end
  
  #Ajax render
  def render_content(partial = nil, options = {})

    options[:partial] = partial.nil? ? action_name : partial.to_s

    options[:destination] ||= :content

    history_url =  "/#{controller_name}/#{action_name}#{Hash.to_url_params(params)}"

    if ajax_request?
      
      render :update do |page|
        page.call_fn "dialog.close()" if cookies[:cd] == 'true'
        
        page.replace_html options[:destination], render(options)
        page.replace_html :user_info, render(:partial => "navigation/user_info")
        page.replace_html :notification, render(:partial => "navigation/notice")
        page.add_simple_history(history_url)
      end
    else
      render_partial options[:partial], true, options[:locals]
    end

    #store last 5 urls
    #not used now
    #    push_history(history_url)
  end

  def render_view(view = nil, layout = true, locals = {})
    view ||= self.action_name
    render :template => "#{self.controller_path}/#{view}", :layout => layout, :locals => locals
  end

  def render_partial(partial = nil, layout = true, locals = {})
    partial ||= self.action_name
    render_view "_#{partial}", layout, locals
  end

  def render_json(options = {})
    render :text => options.to_json
  end

  def render_popup(options = {})

    options[:locals] ||= {}
    options[:locals][:title] ||= options[:title] || ""
    
    options[:partial] ||= action_name

    options[:destination] ||= "dialog_content"
    options[:layout]        = "layouts/dialog" if options[:layout].nil?
    
    render :update do |page|
      page.replace_html options[:destination], render(options)
      page.call_fn "dialog.show()"
    end

    #close dialog false
    cookies[:cd] = 'false'
  end

  class_inheritable_accessor :navigation_value

  def self.navigation(value)
    self.navigation_value = value
  end

  def navigation
    self.navigation_value || :none
  end

  helper_method :current_user, :logged_in?, :logged_in_as?, :admin?,
    :full_version?, :logged_in_and_active?, :partner_url, :current_subdomain, :frame_url, :bigpoint_host?, :hi5_host?, :current_host


  def t(local_key, options = {})
    key = self.class.to_s.downcase.gsub(/::/, '.').gsub(/controller$/, '')
    key = "controllers.#{key}.#{local_key}"
    translate key, options
  end

  def current_user

    #bigpoint implementation
    #force new user
    token = params[:authToken]
    do_force_logout unless token.blank?

    if @current_user.nil?

      #user from hi5 portal
      hi5_id = session[:hi5_user]

      unless hi5_id.blank?
        @current_user = User.find_by_hi5_id_and_deleted(hi5_id, false)
        if @current_user.nil?
          name   = get_user_name(fbsession)
          gender = get_user_gender(fbsession)
          @current_user = User.register_hi5(name, gender, hi5_id)
        end
        session[:user] = @current_user.id
      end

      #simple registration
      user_id = session[:as_user] || session[:user]
      
      @current_user = User.find_by_id(user_id) unless @current_user

      token = cookies[:remember_token] if token.blank?

      if @current_user.nil? && !token.blank?
        @current_user = User.find_by_remember_token(token)
        session[:user] = @current_user.id if @current_user
      end

      if @current_user
        if !admin? && !self.logged_in_as?
          @current_user.adjust_attributes! true
        end
      end
    end
    @current_user
  end

  def page
    @page = params[:page]
    @page = @page.to_i unless @page.nil?
    @page = 1 if @page.blank?
    @page
  end

  def logged_in?
    current_user != nil
  end

  def logged_in_and_active?
    current_user && current_user.active?
  end

  def admin?
    logged_in? && current_user.admin?
  end

  def logged_in_as?
    logged_in? && session[:as_user]
  end

  def full_version?
    !current_user || !current_user.light_version?
  end

  def redirect_to_login(notice = '')
    bigpoint_host? ? redirect_to_with_notice(notice, :controller => 'bigpoint') : redirect_to_with_notice(notice, :controller => 'visitor')
  end

  def redirect(url)
    redirect_to url
  end

  def relogin
    do_logout
    redirect_to_login
  end

  def logout
    logout_internal 
  end

  def logout_as
    u = logout_as_user
    redirect_to admin_users_path(:action => :show, :id => u)
  end

  #FOR TEST ONLY
  def adjust
    current_user.adjust_attributes! true
    redirect_to "/"
  end

  def rescue_action_locally(exception)

    return if exception.to_s.include?("A copy of ApplicationController has been removed from the module tree but is still active")

    super_exception = super

    if !params[:flash].blank?
      erase_results
      render_json(:error => true, :message => "Action ##{request.parameters['action']} NameError (#{exception.to_s})")
      return
    end

    if active_layout.nil?
      # Clears the rendered results, allowing for another render to be performed.
      # Clears the redirected results from the headers, resets the status to 200 and returns
      erase_results

      render :update do |page|
        page.replace_html :content, super_exception
      end
    else
      super_exception
    end
  end

  def current_host
    request.host
  end

  def protocol_with_host
    request.protocol + current_host
  end

  def current_subdomain
    return @current_subdomain unless @current_subdomain.blank?
    @current_subdomain = request.subdomains[1..-1] if request.subdomains.size > 0
    @current_subdomain
  end

  def frame_url
    return @frame_url unless @frame_url.blank?
    if current_subdomain
      partner = Partner.find_by_name(current_subdomain)
      @frame_url = partner.frame_url if partner
    end
    @frame_url
  end

  def partner_url
    return @partner_url unless @partner_url.nil?
    
    partner_name = cookies["7wz_partner"] 
    partner_name = params["partner"] if partner_name.blank?
    
    unless partner_name.blank?
      partner      = Partner.find_by_name(partner_name)
      @partner_url = partner ? partner.host_url : GameProperties::PRODUCTION_HOST
    end
    @partner_url
  end

  def bigpoint_host?
    protocol_with_host == BigpointConfig.host ||
      protocol_with_host == "http://bigpoint.7wizards.com"
  end

  def hi5_host?
    protocol_with_host == hi5_host ||
      protocol_with_host == 'http://www.hi5.7wizards.com'
  end

  
  protected

  def ajax_request?
    (request.xml_http_request? && GameProperties.is_enabled_mode?(:ajax)) || params[:force_ajax]  
  end

  #  def current_events
  #    unless @current_events_requested.nil?
  ##      @current_events = EventHistory.current_events
  #      @current_events_requested = true
  #    end
  #    @current_events
  #  end

  #  def current_events?
  #    !current_events.blank?
  #  end

  def login_as_user(user)
    session[:as_user] = user.id
    @current_user = nil
  end

  def logout_as_user
    u = @current_user
    session[:as_user] = nil
    @current_user = nil
    u
  end

  def logout_internal
    do_logout
    
    redirect_to login_url
  end

  private

  def do_logout
    if current_user
      current_user.activity_logout!
    end
    cookies[:remember_token] = nil
    session[:user] = nil
    session[:as_user] = nil
    session[:hi5_user] = nil

    clear_facebook_cookie
    
    reset_session
  end

  def do_force_logout
    @current_user = nil
    cookies[:remember_token] = nil
    params[:authToken] = nil
    session[:user] = nil
    clear_facebook_cookie
    reset_session
  end

end

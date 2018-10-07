class AdminController < ApplicationController

  layout 'admin'

  before_filter :authorize_access, :except => ['logout', 'login', 'process_login']

  # override
  def check_session
    # skip default functionality ...
  end

  def authorize_access
    if !logged_in? || !current_user.is_admin
      redirect_to :controller => :admin, :action => :login
    end
  end

  def index
  end

  def login
  end

  def process_login
    @user_name = params[:user_name]
    @user_password = params[:user_password]

		user = User.authenticate(@user_name, @user_password)

    if user && user.admin?
      session[:user] = user.id
      redirect_to :action => 'index'
    else
      flash[:notice] = t(:problems_with_login)
      render :login
    end

  end

end

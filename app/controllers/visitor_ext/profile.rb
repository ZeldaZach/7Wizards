module VisitorExt
  module Profile
    
    def profile
      @user = User.f params[:name]
      
      if @user.nil?
        redirect_to root_url 
        return
      end

      if logged_in?
        redirect_to home_path(:action => :index, :anchor => "nav=#{profile_path(:action => :index, :id => @user)}")
        return
      end

      @used_gifts = @user.used_gifts
      @used_curses = @user.used_curses
    end
  end
end

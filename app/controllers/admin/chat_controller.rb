class Admin::ChatController < AdminController

  def index
    @name = params[:name]
    @room = params[:room].blank? ? GameProperties::CHAT_PUBLIC_NAME : params[:room]
    order = params[:order]
    @asc  = params[:asc] == "ASC" ? "DESC" : "ASC"

    @user_id = params[:user_id]
    @user = User.find_by_id(@user_id) if !@user_id.blank?

    case order
    when 'r'
      @order = "chats.report #{@asc}"
    when 'n'
      @order = "users.name #{@asc}"
    when 'lr'
      @order = "chats.last_reporter_id #{@asc}"
    else
      @order = "chats.created_at #{@asc}"
    end

    if @user
      @rooms = Chat.find :all, :select => "room", :group => "room", :conditions => ["room like ? or room like ? ", "%_#{@user.id}", "#{@user.id}_%"],
        :order => "room DESC"
    end
    
    @messages = Chat.paginate :include => [:user], :conditions => ["chats.room = ? and users.name like ? ", @room, "%#{@name}%" ] ,
      :order => @order, :page => page, :per_page => 30
  end

end

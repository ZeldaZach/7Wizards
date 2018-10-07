class Admin::UsersController < AdminController

  def index
    @order = params[:order] || "a_level desc"
    @user_name = params[:name]
    @user_active = params[:active] || true

    if !@user_name.blank?
      sql = <<-SQL
        SELECT *
        FROM users
        WHERE name LIKE ?
        ORDER BY #{@order}
      SQL

      @users = User.paginate_by_sql [sql, "%#{@user_name}%"], :page => params[:page], :per_page => 100
    else
      @users = User.paginate :page => params[:page], :order => @order, :per_page => 100
    end
  end

  def show
    @user = User.find(params[:id])
  end

  def edit
    @user = User.find(params[:id])
  end

  def process_edit
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user])
      flash[:notice] = 'User was successfully updated.'
      redirect_to :action => :show, :id => @user.id
    else
      render :action => :edit
    end
  end

  def avatars
    @user = User.find params[:id]
  end

  def reset_avatar
    user = User.find(params[:id])

    UserAvatarService.reset_avatar!(user)

    redirect_to :action => :avatars, :id => user.id
  end

  def ban
    @user = User.find(params[:id])
    @ban = BanHistory.new
    @ban.user = @user
    @ban.ban = true
  end

  def ban_process
    @ban = BanHistory.new(params[:ban_history])
    @active_messaging = params[:ban_history][:active_messaging]
    ban_end_date = params[:ban_end_date]
    @user = User.find(@ban.user_id)

    if (@ban.ban || @ban.only_messages) && @user.moderator?
      redirect_to_with_notice 'You can\'t ban moderator!', :action => :ban, :id => @user.id
      return
    end

    @user.active_messaging = !@ban.only_messages
    @user.active = !(@ban.ban && ban_end_date.blank?)
    
    if (@ban.ban || @ban.only_messages) && !ban_end_date.blank?
      @ban.ban_end_date = Time.now + ban_end_date.to_i
    else
      @ban.ban_end_date = nil
    end

    @ban.user = @user

    @ban.transaction do
      @ban.save!
      @user.save!
    end

    redirect_to_with_notice @ban.ban ? 'user banned' : 'user is again active', :action => :ban, :id => @user.id
  end

  def login_as
    user = User.find params[:id]
    login_as_user(user)
    redirect_to '/'
  end

  def add_bonus
    @user = User.find(params[:id])
  end

  def process_add_bonus
    user = User.find params[:id]

    money = params[:money] ? params[:money].to_i : 0
    staff = params[:staff] ? params[:staff].to_i : 0
    reason = params[:reason]

    money = [money, 50000].min      # we can give max 50K money bonus
    staff = [staff, 600].min        # we can give max 100 staff bonus

    if reason && (money > 0 || staff > 0)
      if money > 0
        user.a_money += money
        notice = "added #{money} with reason: #{reason}"

        Message.send_bonus_message user, money, 0, reason
      else
        if staff > 0
          user.a_staff += staff
          notice = "added #{staff} with reason: #{reason}"
          Message.send_bonus_message user, 0, staff, reason
        end
      end
    end
    user.save!

    redirect_to_with_notice notice, :action => :show, :id => user.id
  end

  def support
    redirect_to_with_notice tg(:TODO), :action => :show, :id => params[:id]
    #
    #    @user = User.find params[:id]
    #
    #    if @user
    #      @messages = Message.paginate :conditions => ['user_id = ? and kind in (?)', @user.id, Message::SUPPORT + [Message::MESSAGE_FROM_ADMIN]],
    #        :order => 'created_at desc',
    #        :page => params[:page]
    #    else
    #      @messages = []
    #    end
  end

  def chat
    redirect_to_with_notice tg(:TODO), :action => :show, :id => params[:id]
    #
    #    @user = User.find params[:id]
    #    if @user
    #      @messages = Chat.paginate_by_user_id @user.id, :page => params[:page]
    #    else
    #      @messages = []
    #    end
  end

  def messages
    redirect_to_with_notice tg(:TODO), :action => :show, :id => params[:id]
    #
    #    @user = User.find params[:id]
    #
    #    if @user
    #      @messages = Message.paginate :conditions => ['user_id = ? and kind in (?)', @user.id, Message::MESSAGE_TO],
    #        :order => 'id desc',
    #        :page => params[:page]
    #    else
    #      @messages = []
    #    end
  end

  def payments
    @user = User.find params[:id]
    @payments = PaymentLog.user_payments(@user, page)
  end

  def send_message
    redirect_to_with_notice tg(:TODO), :action => :show, :id => params[:id]
    #
    #    user = User.find params[:id]
    #    text = params[:message]
    #    if user && !text.blank?
    #      Message.send_admin_message user, text
    #    end
    #    redirect_to :action => :support, :id => params[:id]
  end
  
end

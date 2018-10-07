class Wizards::ChatController < WizardsController

  def index
    render :nothing => true
  end

  def history
    
    render :update do |page|
      result = {:data => {:pubid => params[:pubid], :history => Chat.last_messages(params[:room])}}
      page.call_fn "chat.onCallbackHistory(#{result.to_json})"
    end
  end

  def users
    current_user.register_chat_activity!
    render :update do |page|
      result = {:data => {:action=> params[:act], :list => Chat.last_chat_users(params[:name], params[:g])}}
      page.call_fn "chat.onCallbackUsers(#{result.to_json})"
    end
  end

  def do_send
    room    = params[:room]
    message = params[:message]
    Chat.send!(current_user, message, room) if(!room.blank? && !message.blank?)
    render :nothing => true
  end

  def block
    user = current_user
    id = params[:id]

    @ban_user = User.find_by_id(id)
    r = ChatRules.can_block_user(user, @ban_user, 1, "ok")
    @ban_times = GameProperties::CHAT_BAN_TIMES

    unless r.allow?
      flash[:notice] = r.message
    end
    render_popup :title => t(:block_user, :name => @ban_user.name)
  end

  def do_block
    user   = current_user
    id     = params[:id]
    time   = params[:time].to_i
    reason = params[:reason]

    @ban_user = User.find_by_id(id)

    r = ChatRules.can_block_user(user, @ban_user, time, reason)

    if r.allow?
      @ban_user.ban! time, {
        :public_reason => reason,
        :private_reason => "banned messaging by moderator on chat",
        :banned_by => user,
        :only_messages => true
      }
      Ape.block(@ban_user.name, reason)
      render_popup(:partial => "block", :title => t(:block_user, :name => @ban_user.name))
    else
      options = {}
      options[:id]     = params[:id]
      options[:action] = "block"
      #      options[:dialog_error] = true
      redirect_to_with_notice(r.message, options)
    end
  end

  def warning
    @message = t(:warning_min_level, :level => GameProperties::CHAT_MIN_LEVEL)
    render_popup :title => "Warning"
  end

  def can_connect
    session = ActiveRecord::SessionStore::Session.find_by_session_id(params[:session_id])
    user    = User.find_by_id(session.data[:user]) if session && session.data[:user]
    r = ChatRules.can_connect(user)
    #    render :text => r.allow? ? "OK" : "FAIL"
    render :text => "FAIL"
  end
  
end

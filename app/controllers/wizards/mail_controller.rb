class Wizards::MailController < WizardsController

  before_filter :calculate_new_messages

  include Wizards::MailExt::UserMessages

  def index
    redirect_to mail_path(:action => :user_messages)
  end
  
  def notifications
    id = params[:id]
    @notificatons = Message.user_notifications(@user, page)
    @selected_message = Message.find_by_id(id) if !id.blank?
    Message.mark_events_as_read!(@user)
  end

  def fight_logs
    id = params[:id]
    unless id.blank?
      log = FightLog.find_by_id(id)
      r  = FightRules.can_see_fight_log(@user, log)
      if r.allow?
        @selected_fight = log
      end
    end

    @fights = Message.get_fights(@user, page) if @selected_fight.nil?
    
    Message.mark_fights_as_read!(@user)
  end

  def remove_notification
    id = params[:id]
    if !id.blank?
      message = Message.find_by_id(id)
      message.destroy
    end
    redirect_to :action => :notifications
  end

  def friend_requests
    @relations = Relation.paginate_friend_requests @user, :page => page
  end

  def clan_messages
    @user = current_user
    @clan = @user.clan
    @history = ClanMessage.clan_history(@clan, page)
    ClanMessage.mark_history_as_read!(@user)
  end

  def new_clan_message
    render_popup :title => t(:new_message)
  end

  def new_clan_message_process
    message = params[:message]
    
    r = MailRules.can_send_clan_message(@user, message)
    if r.allow?
      ClanMessage.send_message(@user.clan, message, @user)
      redirect_to mail_path(:action => :clan_messages)
    else
      redirect_to_with_notice r, mail_path(:action => :new_clan_message)
    end
  end
  
  private

  def calculate_new_messages
    @user = current_user
    @new_incoming = Message.unread_incoming_count(@user)
    @new_events   = Message.unread_events_count(@user)
    @new_friens   = Relation.count_friend_requests @user
    @new_history  = ClanMessage.unread_history_count(@user)
    @new_fights   = Message.unread_fight_count(@user)


    Message.mark_messages_as_read!(@user)
  end
end

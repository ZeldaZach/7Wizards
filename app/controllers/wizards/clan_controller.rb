class Wizards::ClanController < WizardsController

  before_filter :prepare

  include Helpers::AvatarUrlHelper
  include Wizards::ClanExt::War
  
  def index
    @user = current_user

    if @user.clan
      redirect_to :action => :details
      return
    end

    @owner_name = params[:owner_name]
    @clan_name  = params[:clan_name]
    action      = params[:a]

    filter = {}

    if action == 'o'
      filter[:owner_name] = @owner_name
    elsif action == 'n'
      filter[:clan_name] = @clan_name
    end

    @clans = Clan.find_the_best_clans(filter, "created_at DESC", page, 30 * 5, 30)

    if @clans.size == 0 && page == 1
      if action == 'o'
        notice = t(:owner_with_name_empty, :name => @owner_name)
      elsif action == 'n'
        notice = t(:clan_with_name_empty, :name => @clan_name)
      end
      flash[:notice] = notice
    end
  end

  def create
    @user = current_user
    r = ClanRules.can_create_clan(@user)
    if r.allow?
      @clan = Clan.new
    else
      redirect_to_with_notice r, :action => 'index'
    end
  end

  def process_create
    @user = current_user

    r = ClanRules.can_process_create_clan(@user)
    if r.allow?
      @clan = Clan.new
      populate_edit_params @clan
      @clan.creator = @user
      @clan.owner = @user

      registered = false
      
      @clan.transaction do
        registered = @clan.register
        if registered
          @user.clan = @clan
          @user.save!

          @user.done_task!(TutorialClan::NAME)
        end
      end

      if registered
        ClanMessage.log_created(@clan)
        redirect_to :action => 'details'
      else
        flash[:notice] = @clan.errors.full_messages.first
        render_content :create
      end
    else
      redirect_to_with_notice r, :action => 'index'
    end
  end

  def edit
    @user = current_user
    r = ClanRules.can_edit_clan(@user)
    if r.allow?
      @clan = @user.clan
    else
      redirect_to_with_notice r, :action => 'details'
    end
  end

  def process_edit
    @user = current_user
    return if (@clan = get_clan_required(@user)).nil?

    populate_edit_params @clan

    r = ClanRules.can_process_edit_clan(@user)
    if r.allow?
      @clan.a_money -= GameProperties::CLAN_CHANGE_PRICE
      if @clan.save
        redirect_to :action => 'details'
      else
        flash[:notice] = @clan.errors.first
        render_content :edit
      end
    else
      redirect_to_with_notice r, :action => 'details'
    end
  end

  def details
    @user = current_user
    @clan = params[:id].blank? ? @user.clan : Clan.find(params[:id])

    if @clan
      @users = @clan.users
      render_content :details
    else
      redirect_to :action => 'index'
    end
  end

  def join
    @user = current_user
    @clan = Clan.find params[:id]

    r = ClanRules.can_join(@user, @clan)
    if r.allow?
      render_content
    else
      redirect_to_with_notice r, :action => 'details', :id => @clan.id
    end
  end

  def join_request_send
    user = current_user
    clan = Clan.find params[:id]
    message = params[:message]

    r = ClanRules.can_send_join_request(user, clan, message)
    if r.allow?
      ClanMessage.request_join clan, user, message
      redirect_to_with_notice t(:joined_request, {:name => clan.name}),
        :action => 'details', :id => clan.id
    else
      redirect_to_with_notice r, :action => 'details', :id => clan.id
    end
  end

  def join_requests
    @user = current_user
    @page = page
    return if (@clan = get_clan_required(@user)).nil?

    @messages = ClanMessage.clan_join_requests @clan, @page
    @on_war = @clan.on_war?
    flash[:notice] = t(:join_requests_on_war) if @on_war
    
    render_content
  end

  def process_join
    user = User.find params[:id]
    clan = owner_clan
    if clan && user
      action = params[:a]

      if ClanMessage.requested_join? clan, user
        if action == 'join'
          r = ClanRules.can_process_join(user, clan)
          if r.allow?
            user.transaction do
              user.clan = clan
              user.save!


              clan.s_month_joins += 1
              clan.save!
              
              user.done_task!(TutorialClan::NAME)
            end

            ClanMessage.log_user_joined clan, user
            ClanMessage.destroy_user_join_requests user

            redirect_to_with_notice t(:joined_clan, {:user => user.name, :name => clan.name}), :action => 'join_requests'
          else
            redirect_to_with_notice r, :action => 'join_requests'
          end
        else
          ClanMessage.destroy_user_clan_join_requests(user, clan)
        end

      end

      redirect_to :action => 'join_requests'
    else
      redirect_to :action => 'details'
    end
  end

  def process_kick
    user = User.find params[:id]
    owner = current_user
    r = ClanRules.can_kick_from_clan(owner, user)
    if r.allow?
      user.e_last_clan_leave_time = Time.now
      user.clan = nil
      user.save!

      ClanMessage.log_user_kicked(owner.clan, user)
      redirect_to_with_notice t( :user_kicked, { :name => owner.clan.name, :user => user.name } ), wizards_path(:action => :confirm_dialog, :callback => clan_path(:action => 'users_list'))
    else
      redirect_to_with_notice r, wizards_path(:action => :confirm_dialog, :callback => clan_path(:action => 'details'))
    end
  end

  def leave
    user = current_user
    return if (clan = get_clan_required(user)).nil?

    r = ClanRules.can_leave_clan(user)
    if r.allow?

      user.transaction do
        user.e_last_clan_leave_time = Time.now
        if user.is_clan_creator?
          clan.creator = clan.owner
          clan.save!
        elsif user.is_clan_owner?
          clan.owner = clan.creator
          clan.save!
        end
        user.clan = nil
        user.save!
      end

      ClanMessage.log_user_leave(clan, user)
      
      redirect_to_with_notice t(:leave_clan, {:name => clan.name}), wizards_path(:action => :confirm_dialog, :close => true, :callback => clan_path(:action => 'index'))
    else
      redirect_to_with_notice r, wizards_path(:action => :confirm_dialog,  :callback => clan_path(:action => 'details', :id => clan.id))
    end

  end
  
  def donate
    @user = current_user
    return if (@clan = get_clan_required(@user)).nil?

    @last_donates = ClanMessage.last_donates(@clan, params[:page])
    render_content
  end

  def process_donate
    user = current_user
    return if (clan = get_clan_required(user)).nil?

    RedisLock.lock "clan_donate_#{clan.id}" do
      money = params[:money].blank? ? 0 : params[:money].to_i 
      staff2 = params[:staff2].blank? ? 0 : params[:staff2].to_i

      price = Price.new(user, money, 0, staff2, "donate")
      
      r = ClanRules.can_donate(price)
      if r.allow?
        clan.a_money += money
        clan.a_staff2 += staff2

        price.pay true, "clan_items"

        clan.s_add_user_payment price

        clan.transaction do
          clan.save!
          user.save!
        end

        ClanMessage.log_donate clan, price

        redirect_to_with_notice({:info => t(:donate_clan, {:money => money, :staff2 => staff2})},
          :action => 'donate')
      else
        redirect_to_with_notice r, :action => 'donate'
      end
    end

    redirect_to_with_notice tg(:wait_locked), :action => 'donate'
  end

  def reset_donates
    clan = owner_clan
    if clan
      clan.s_reset_users_payments
      clan.save!
    end
    redirect_to :action => 'users_list'
  end

  def users_list
    @user = current_user
    @clan = params[:id].blank? ? @user.clan : Clan.find(params[:id])

    if @clan.nil?
      redirect_to :action => :index
      return
    end

    @on_war = @clan.on_war?
    @clan_owner = @user.is_clan_owner?

    @order  = params[:order_users]
    @user_name  = params[:user_name]
    case @order
    when "n"
      sort = "name ASC"
    when "l"
      sort = "a_level DESC"
    else
      sort = "name ASC"
    end

    @users = @clan.users.user_name(@user_name).user_order(sort)

    sorting = proc { |payment|
      @users.sort! { |u1, u2|
        up1 = @clan.s_get_user_payment(u1)[payment]
        up2 = @clan.s_get_user_payment(u2)[payment]
        up2 <=> up1
      }
    }
    
    if @order == "p"
      @users = sorting.call(:money)
    elsif @order == "s2"
      @users = sorting.call(:staff2)
    end

    render_content
  end

  def improvements
    @user = current_user
    return if (@clan = get_clan_required(@user)).nil?

    @items = AllClanItems.all
    @on_war = @clan.on_war?
    @clan_owner = @user.is_clan_owner?

  end

  def improve
    user = current_user
    clan = user.clan

    key = params[:item]
    item = AllClanItems.get(key)

    r = ClanRules.can_improve(user, clan, item)
    if r.allow?
      item.extend(clan)
      clan.save!
      notice = {:info => t(:improve_notice, :name => item.title, :level => item.get_level(clan))}
    else
      notice = r.message
    end

    redirect_to_with_notice(notice, :action => :improvements)
  end

  def get_ownership
    user = current_user
    clan = user.clan

    r = ClanRules.can_get_ownership(user, clan)
    if r.allow?
      clan.owner = user
      clan.save!

      redirect_to :action => 'details'
    else
      redirect_to_with_notice r, :action => 'details'
    end
  end

  def change_owner
    user = current_user
    new_owner = User.find params[:id]
    clan = user.clan

    r = ClanRules.can_change_owner(user, clan, new_owner)
    if r.allow?
      clan.owner = new_owner
      clan.save!

      redirect_to wizards_path(:action => :confirm_dialog, :close => true, :callback => clan_path(:action => 'details'))
    else
      flash[:notice] = r.message
      redirect_to wizards_path(:action => :confirm_dialog, :close => true, :callback => clan_path(:action => 'users_list'))
    end
  end

  def kill

    user = current_user
    clan = user.clan

    r = ClanRules.can_kill_clan(user, clan)
    if r.allow?
      clan.transaction do
        clan.users.each do |clan_user|
          clan_user.e_last_clan_leave_time = Time.now
          clan_user.save
        end

        clan.users = []
        clan.active = false
        clan.save!
      end

      redirect_to_with_notice({:info => t(:kill_clan, {:name => clan.name})}, clan_path(:action => 'index'))
    else
      redirect_to_with_notice r, clan_path(:action => 'details', :id => clan.id)
    end
  end

  protected

  def populate_edit_params(clan)
    clan_params = params[:clan]
    if clan_params
      clan.name = clan_params[:name]
      clan.description = clan_params[:description]
      if !clan_params[:avatar].blank?
        clan.avatar = clan_params[:avatar]
      else
        g = available_clan_images[0]
        clan.avatar = "#{g};#{g}"
      end
    end
  end

  def owner_clan(user = nil)
    user ||= current_user
    user.is_clan_owner? ? user.clan : nil
  end

  def get_clan_required(user)
    clan = user.clan
    redirect_to :action => :index if !clan
    clan
  end

  private
  
  def prepare
    clan = owner_clan
    @new_requests = ClanMessage.clan_join_requests_count(clan) if clan
  end

end

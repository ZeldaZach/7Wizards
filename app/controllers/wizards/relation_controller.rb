class Wizards::RelationController < WizardsController

  include Wizards::RelationExt::Gifts

  before_filter :prepare_navigation

  def index
    @kind      = params[:kind] || Relation::KIND_FRIEND
    @user_name = params[:user_name]
    @order    = params[:order_best]
    
    filter = {:name => @user_name}

    case @order
    when "m"
      sort = "s_loot_money DESC"
    when "l"
      sort = "a_level DESC"
    when "d"
      sort = "s_total_damage DESC"
    when "gf"
      filter[:gender] = "f"
      sort = User::BEST_ORDER
    when "gm"
      filter[:gender] = "m"
      sort = User::BEST_ORDER
    when "o"
      filter[:online] = true
      sort = User::BEST_ORDER
    else
      @order = 'f'
      sort = User::BEST_ORDER
    end

    where = "(u.name like ? AND (r.active = 1 and r.user_id = #{@user.id} and kind = '#{@kind}'))"
    conditions = ["%#{filter[:name]}%"]

    unless filter[:gender].blank?
      where += " and u.gender = ?"
      conditions << filter[:gender]
    end

    if filter[:online]
      where += " and u.last_activity_time > ?"
      conditions << GameProperties::USER_ACTIVE_PERIOD.ago
    end
    
    sql =<<-SQL
      SELECT u.id, u.name, u.a_level, u.a_reputation, u.s_loot_money, u.s_total_damage, r.message, r.relative_id as user_id, u.gender, u.avatar, u.last_activity_time
      FROM relations as r
      LEFT JOIN users as u on (u.id = r.relative_id)
      WHERE #{where}
      ORDER BY #{sort}
    SQL

    @relations = Relation.paginate_by_sql [sql] + conditions, :page => page, :per_page => 30
    
  end

  def friend_requests
    @relations = Relation.paginate_friend_requests @user, :page => params[:page]
  end

  def add
    @relation = Relation.new
    @relation.relative = User.find(params[:id])
    @relation.kind = params[:kind]
    @relation.request_message = tf(Relation, :default_request_message)
    @relation.message = tf(Relation, :default_bookmark_message)
    render_popup :title => t("add_user_#{params[:kind]}", :name => @relation.relative.name)
  end

  def process_add
    relation = params[:relation]
    
    unless relation.nil?
      
      @relation = Relation.new
      @relation.user = @user
      @relation.relative = User.find params[:id]
      @relation.kind =  relation[:kind]
      @relation.message = relation[:message]
      @relation.request_message = relation[:request_message]
    

      if @relation.is_flagged?
        @user.done_task!(TutorialFlagging::NAME)
      end

      r = RelationRules.can_create_relation(@user, @relation)
      if r.allow?

        if @relation.is_friend?
          @relation.active = false # friend relation should be approved
          @user.done_task!(TutorialFriends::NAME)
        else
          @relation.active = true
          @relation.request_message = nil # request message is not used for other types
        end
        
        @relation.save
        @dialog_callback_url = profile_path(:id => params[:id])
        render_popup :title => t("add_user_#{relation[:kind]}", :name => @relation.relative.name), :partial => "add"
      else
        redirect_to_with_notice r, relation_path(:action => :add, :id => params[:id], :kind => @relation.kind)
      end
    end
    redirect_to profile_path(:id => params[:id])
  end

  def invite
  end

  def delete
    relative = User.find(params[:id])
    kind = params[:kind]
    
    if relative && kind
      Relation.destroy_all_relations(@user, relative, kind)
      if params[:profile]
        callback_url = profile_path( :action => :index, :id => relative.id )
      else
        callback_url = profile_path(:action => :index, :kind => kind, :page => params[:page])
      end
      description = t("destroy_description_#{kind}")
      redirect_to wizards_path(:action => :confirm_dialog, :confirmation => description, :callback => callback_url)
    else
      redirect_to :action => :index
    end
  end

  def accept_request
    relative = User.find(params[:id])
    if relative
      request = Relation.get_friend_request relative, @user

      r = RelationRules.can_accept_relation(@user, request)
      if r.allow?
        request.transaction do
          request.active = true
          request.save!

          request = Relation.new :user => @user,
            :relative => relative,
            :kind => Relation::KIND_FRIEND,
            :active => true
          request.save!

        end
      else
        redirect_to_with_notice r, :action => :friend_requests
      end
    end
    redirect_to params[:callback_url]
  end

  def reject_request
    relative = User.find params[:id]
    if relative
      Relation.destroy_all_relations @user, relative, Relation::KIND_FRIEND
    end
    redirect_to params[:callback_url]
  end

  def block
    relative = User.find_by_id(params[:id])

    r = RelationRules.can_block_user(@user, relative)

    if r.allow?
      relation = Relation.new :user => @user,
        :relative => relative,
        :kind => Relation::KIND_IGNORE,
        :active => true
      
      relative.transaction do
        relation.save!
        Message.delete_all_from(@user, relative)
      end
      redirect_to mail_path
    else
      redirect_to_with_notice r, mail_path
    end
  end

  protected

  def prepare_navigation
    @user = current_user
    @requests_count = Relation.count_friend_requests @user
    @friends_count  = Relation.count_by_kind_and_user Relation::KIND_FRIEND, @user
    @bookmark_count = Relation.count_by_kind_and_user Relation::KIND_BOOKMARK, @user
  end

end

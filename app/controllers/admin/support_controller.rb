class Admin::SupportController < AdminController

  def index
    @page = params[:page] || 1
    @mode = params[:mode]
    @category = params[:category]

    category_condition = ''
    if !@category.blank?
      if @category == 'other'
        category_condition = " and (extra = '#{@category}' or extra is null) "
      else
        category_condition = " and extra = '#{@category}' "
      end
    end

    if @mode == 'moder'
      condition = <<-SQL
        kind in (?) #{category_condition} and user_id in
        (select id from users where is_moderator = ?)
      SQL
      @messages = Message.paginate :conditions => [condition, Message::SUPPORT_Q_NEW, true], :page => @page
      return
    end

    if @mode == 'paid'
      time = 1.month.ago.to_formatted_s :db
      condition = <<-SQL
        kind in (?) #{category_condition} and user_id in
        (select user_id from (select m.user_id, sum(m.arm_paid) arm
          from m_gates_histories m 
          where kind = #{MGatesHistory::SPEND_MONEY} and created_at > '#{time}'
          group by m.user_id order by arm desc limit 20) m)
      SQL
      @messages = Message.paginate :conditions => [condition, Message::SUPPORT_Q_NEW], :page => @page
      return
    end

    if @mode == 'bugs'
      @messages = Message.paginate :conditions => ["kind in (?) and extra = ?", Message::SUPPORT_Q_NEW, 'bug'], :page => @page
      render :bugs
      return
    end
    
    @messages = Message.paginate :conditions => ["kind in (?) #{category_condition}", Message::SUPPORT_Q_NEW], :page => @page
  end

  def answer
    @page = params[:page]
    @message = Message.find params[:id]
    @mode = params[:mode]
    @category = params[:category]
    
    if @message && @message.user
      @messages = Message.all :conditions => ['user_id = ? and kind in (?)', @message.user.id, Message::SUPPORT + [Message::MESSAGE_FROM_ADMIN]],
        :limit => 10, :order => 'created_at desc'
    else
      @messages = []
    end
  end

  def reply
    if params[:ignore]
      Message.ignore_question params[:id]
    else
      if params[:message].blank?
        message = Message.find params[:id]
        message.extra = params[:extra]
        message.message = params[:question]
        message.save!
      else
        Message.reply_question params[:id], params[:question], params[:message], params[:pub_checkbox]
      end
    end
    redirect_to :action => 'index', :page => params[:page], :mode => params[:mode], :category => params[:category]
  end

  def not_a_bug
    message = Message.find params[:id]
    message.extra = nil
    message.save!

    redirect_to :action => 'index', :page => params[:page], :mode => params[:mode], :category => params[:category]
  end

  def history
    @user_name = params[:name]

    if !@user_name.blank?
      sql = <<-SQL
        SELECT m.*
        FROM messages m
        JOIN users u on u.id = m.user_id
        WHERE u.name LIKE ? AND m.kind in (?)
        ORDER BY created_at desc
      SQL

      @messages = Message.paginate_by_sql [sql, "%#{@user_name}%", Message::SUPPORT], :page => params[:page]
    else
      @messages = Message.paginate_by_kind Message::SUPPORT, :page => params[:page]
    end
  end

  def edit_message
    @message = Message.find_by_id_and_kind(params[:id], Message::SUPPORT)
  end

  def process_edit_message
    @message = Message.find_by_id_and_kind(params[:id], Message::SUPPORT)
    if @message.update_attributes(params[:message])
      redirect_to :action => :history
    else
      render :edit_message
    end
  end

  def delete_message
    @message = Message.find_by_id_and_kind(params[:id], Message::SUPPORT)
    @message.destroy

    redirect_to :action => params[:answer] ? :index : :history, :page => params[:page], :mode => params[:mode], :category => params[:category]
  end

end

class Wizards::DragonController < WizardsController

  include Wizards::Ext::Fight
  
  def index
    @user = current_user
    @user_a        = @user.user_attributes(:fight_user => true)
    @current = Dragon.current
    if @current
      @description = @current.description
      @active = @current.active?
      @current = @current.user_attributes
    else
      redirect_to home_path(:action => :index)
    end

  end

  def dragon_history
   sql = <<-SQL
           select * from dragons
            where arrived_at = (select distinct(arrived_at) from dragons where killed = true order by id desc limit 1) and killed = 1
            order by id ASC
    SQL

    @dragons = Dragon.find_by_sql sql
    @dragons = Dragon.find(:last) if @dragons.empty?

    sql = <<-SQL
        select sum(money) m, sum(staff2) s from dragons
        where arrived_at = (select distinct(arrived_at) from dragons where killed = true order by id desc limit 1) and killed = 1
    SQL

    r = Dragon.connection.select_one(sql)
    @dragons_money, @dragons_staff2 = r['m'] || 0, r['s'] || 0

    render_popup(:title => "The story thus far", :layout => "layouts/dialog_middle")
  end

  def fight
    @is_flash = params[:flash]
    
    if @is_flash
      #flash params
      dragon_level = flash_params["dragon_level"]
    else
      dragon_level = params[:dragon_level]
    end
    
    unless confirm_drid
      render_fight_result(:success => false, :url => dragon_url, :message => tg(:drid_is_not_confirmed))
      return
    end
    
    user = current_user
    dragon = Dragon.current

    unless dragon
      redirect_to :action => :index
      return
    end

    impl = Fight::Dragon.new(user, dragon)
    Fight::Base.set_fight_locks user, dragon do

      r = FightRules.can_fight_with_dragon(user, dragon)
      if !r.allow?
        render_fight_result(:success => false, :url => dragon_url, :message => r.message)
        return
      end

      f = impl.fight!

      Message.create_fight_dragon(f)

      if f.opponent_health_after_fight < GameProperties::DRAGON_MIN_HEALTH
        Helpers::DragonHelper.kill_dragon user
      end
      
      @skills_changed = (dragon.a_level.to_i != dragon_level.to_i) || !dragon.active?

      if @skills_changed && dragon.a_level != GameProperties::DRAGON_MAX_LEVEL
        d = Dragon.current
        desc = d.description 
      else
        desc = dragon.description
      end
      
      render_fight_result(:success => true, :won => f.user_won, :log => f, :log_id => f.id, :refresh => @skills_changed,
        :user_pet_active => user.pet_active?, :level => dragon.a_level, :user => @user, :description => desc)
    end

    render_fight_result(:success => false, :message => t(:fight_locked), :url => dragon_url)
  end

end
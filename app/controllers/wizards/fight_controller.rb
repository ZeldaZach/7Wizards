class Wizards::FightController < WizardsController

  include Wizards::Ext::Fight

  before_filter :find_filter, :only => [:find_id, :find_level, :find_name]
  
  def index
    @user = current_user
    
    r = FightRules.can_fight_find(@user)
    if r.allow? 
      redirect_to fight_path(:action => :find_level, :level => @user.a_level)
    else
      redirect_to_with_notice r, fight_path(:action => :index_ext)
    end
  end

  def index_ext
    @user = current_user
    @user_a        = @user.user_attributes(:fight_user => true)
    @price         = @user.a_level
    @find_by_level = @user.a_level
    
    render_content :index
  end

  def find_id
    id = params[:id]
    @opponent = User.find_by_id(id)
    warnings
    render_content :index
  end

  def find_level
    conditions_base =  ["a_level = ? and created_at < ?", @find_by_level, GameProperties::USER_REGISTRATION_FIGHT_FREE_TIME.ago]
    
    conditions_base = User.add_holiday_conditions conditions_base
    conditions_base = GameVoodooItem.add_fight_conditions conditions_base
    
    conditions_extended     = conditions_base.clone
    conditions_extended[0] += " and g_cloaking <= ? "
    conditions_extended << @user.g_clairvoyance

    # we should add id in the end to force mysql to use correct index
    conditions_extended[0] += " and id != ?"
    conditions_extended    << @user.id

    count = User.active.count :conditions => conditions_extended
          
    @opponent = User.active.find :first,
      :conditions => conditions_extended,
      :offset => rand(count)

    if @opponent.nil?
      #conditions without cloaking
      conditions =  ["a_level > ? and a_level <= ? "]
      conditions << [@find_by_level - 2, 0].max
      conditions << @find_by_level + 1
      conditions[0] += " and id != ?"
      conditions    << @user.id

      count = User.active.count :conditions => conditions

      @opponent = User.active.find :first,
        :conditions => conditions,
        :offset => rand(count)
    end

    if @opponent.nil?
      redirect_to_with_notice(t(:no_body_found_with_level), fight_path(:action=>:index_ext))
      return
    end
    warnings
    render_content :index
  end

  def find_name
    name = params[:name]
    @opponent = User.active.find(:first, :conditions => ["name = ? AND id != ?", name, @user.id])
    if @opponent
      warnings
      render_content :index
    else
      redirect_to_with_notice(t(:no_body_found_with_name, :name => name), fight_path(:action => :index_ext))
    end
  end

  def fight
    
    @is_flash = params[:flash]

    if @is_flash
      #flash params
      opponent_id = flash_params["id"]
      u_md5 = flash_params["u_md5"]
      o_md5 = flash_params["o_md5"]
    else
      opponent_id = params[:id]
      u_md5 = params[:u_md5]
      o_md5 = params[:o_md5]
    end

    @user = current_user
    @opponent = User.find_and_adjust opponent_id

    if @opponent.nil?
      render_fight_result(:success => false, :url => fight_url, :message => t(:cant_find_opponent_by_id))
      return
    end

    impl = Fight::Base.get_implementation(@user, @opponent)

    impl.set_fight_locks @user, @opponent do

      #user attributes  md5, check
      opponent_md5 = (@opponent.user_attributes.md5 != o_md5)
      r = FightRules.can_fight_with_opponent(@user, @opponent, opponent_md5)
      if !r.allow?
        Message.create_fight_try @user, @opponent
        render_fight_result(:success => false, :url => fight_url(:action => :find_id, :id => @opponent.id), :message => r.message, :refresh => opponent_md5)
        return
      end

      fight = impl.new(@user, @opponent)
      result = fight.fight!

      @skills_changed = (@user.user_attributes.md5 != u_md5) || (@opponent.user_attributes.md5 != o_md5)

      Message.create_fight(result)

      @user.done_task!(TutorialFight::NAME)

      render_fight_result(:success => true, :won => result.user_won, :log => result, :refresh => @skills_changed,
        :log_id => fight.fight_id, :user_pet_active => @user.pet_active?, :opponent_pet_active => @opponent.pet_active?, :user => @user)
      return
    end

    render_fight_result(:success => false, :message => t(:fight_locked), :url => fight_url)

  end

  private

  def find_filter
    @user = current_user
    @user_a = @user.user_attributes(:fight_user => true)
    @price = @user.a_level
    
    @find_by_level = params[:level].to_i
    @find_by_level = @user.a_level if @find_by_level.blank? || @find_by_level==0

    r = FightRules.can_fight_find(@user)
    if !r.allow?
      redirect_to_with_notice(r, fight_path(:action => :index_ext))
    else
      @user.spend_money(@price, "fight_find", "")
      @user.save

    end
  end

  def warnings
    if @user.a_level - @opponent.a_level > GameProperties::FIGHT_PET_LEVEL_DIFF && flash[:notice].blank?
        flash[:notice] = t(:kill_pet_bonus, :level => GameProperties::FIGHT_PET_LEVEL_DIFF)
    end
    @on_war = @user.on_war_with_user?(@opponent)

#    @is_max_fights_pet_day = FightRules.is_max_fight(@user)
    
#    reputation_level_diff = GameProperties::FIGHT_REPUTATION_LEVEL_DIFF
#    if flash[:notice].blank? && @opponent && @user.a_level > @opponent.a_level + reputation_level_diff && !@on_war
#      diff = [@user.a_reputation, @user.a_level - @opponent.a_level - reputation_level_diff].min
#      flash[:notice] = t(:reputation_will_decreased, :repuatation => diff)
#    end
  end

  
end

class Wizards::ProfileController < WizardsController

  include Wizards::ProfileExt::Flash

  def index
    id = params[:id]
    @show_flash = !params[:show_flash].blank?
    
    @user = User.find_by_id(id)
    @user = current_user if @user.nil?
    @user_a = @user.user_attributes
    @used_gifts = @user.used_gifts
    @used_curses = @user.used_curses
    @achivements = AllGameItems::ALL_ACHIVEMENTS
    @friends_count = Relation.count_by_kind_and_user(Relation::KIND_FRIEND, @user)
    @can_vote = @user != current_user && AvatarVoting.can_vote?(current_user, @user)
  end

  def dressup
    @user = current_user
    @user_avatars = @user.user_avatars
    @available_avatars = @user.unused_avatars
  end

  def train
    u = current_user
    @user = u

    attribute = params[:a]
    if attribute
      r = ProfileRules.can_train_attribute(u, attribute)
      if r.allow?
        RedisLock.lock "user_train_#{u.id}" do
          price = UserAttributesGrowthTable.get_price(u, attribute.intern)
          u.spend_money(price, "train", "attribute: #{attribute}")
          
          u['a_' + attribute] += 1
          u.save!

          u.done_task!(TutorialTrain::NAME)
        end
      else
        flash[:notice] = r.message
      end
    end

    @max_value = [ u.a_power, u.a_protection, u.a_dexterity, u.a_skill, u.a_weight ].max

    @prices = {
      "a_power" => UserAttributesGrowthTable.get_power_price(u),
      "a_protection" => UserAttributesGrowthTable.get_protection_price(u),
      "a_dexterity" => UserAttributesGrowthTable.get_dexterity_price(u),
      "a_skill" => UserAttributesGrowthTable.get_skill_price(u),
      "a_weight" => UserAttributesGrowthTable.get_weight_price(u)
    }

  end

  def extend
    user = current_user
    item = AllGameItems.get params[:g]

    r = ProfileRules.can_extend user, item
    if r.allow?
      item.extend user
      user.save!

      user.done_task!(TutorialAdditionaltalents::NAME)
      notice = { :info => t(:you_extended_item, { :name => item.title })}
      redirect_to_with_notice notice, :action => :train
    else
      redirect_to_with_notice r, :action => :train
    end

  end

  def equipment
    @user = current_user

    @groups = []
    @groups << { :name => :used, :items => @user.used_clothes_items + @user.used_amulets }
    @groups << { :name => :available, :items => @user.available_clothes_items + @user.available_amulets }
    @groups << { :name => :powerup, :items =>  AllGameItems::POWER_UP}
    @groups << { :name => :gift, :items => @user.available_gifts }
    @groups << { :name => :curse, :items => @user.available_curses }

  end

  def use
    user = current_user
    item = AllUserItems.find_by_key params[:item]

    used_from_category = item.get_used_from_category(user)
    used_from_category.takeoff(user) if used_from_category

    r = ProfileRules.can_use_item(user, item)
    if r.allow?
      item.use(user)
      user.save!

      user.done_task!(TutorialEquipment::NAME, :item_key => item.key)
      
      redirect_to_with_notice({:info => t(:you_used_item, :name => item.title)}, :action => :equipment)
    else
      redirect_to_with_notice r, :action => :equipment
    end
  end

  def takeoff
    user = current_user
    item = AllUserItems.find_by_key params[:item]

    r = ProfileRules.can_takeoff_item(user, item)
    if r.allow?
      item.takeoff(user)
      user.save!
      redirect_to_with_notice({:info =>t(:you_takeoff_item, :name => item.title)}, :action => :equipment)
    else
      redirect_to_with_notice r, :action => :equipment
    end
  end

  def update_message
    @user = current_user
    user_params  = params[:user]
    r = ProfileRules.can_edit_descriptions(@user)
    if r.allow? && !user_params.nil?
      attacker    = user_params[:attacker_message]
      description = user_params[:description]
      @user.attacker_message = ERB::Util.h(attacker).cyr_latin_only
      @user.description = ERB::Util.h(description).cyr_latin_only

      @user.done_task!(TutorialAboutme::NAME)

    else
      redirect_to_with_notice r, profile_path(:action => :index, :id => @user.id)
      return
    end
    
    if @user.valid?
      @user.save!
      redirect_to :action => :index, :id => @user.id
    else
      redirect_to_with_notice @user.errors.full_messages.first, profile_path(:action => :index, :id => @user.id)
    end
    
  end

  def vote
    user_id = params[:id]

    user  = User.find_by_id(user_id)
    voter = current_user

    r = ProfileRules.can_vote(voter, user)

    if r.allow?
      AvatarVoting.vote!(voter, user)
      @dialog_callback_url = profile_path(:action => :index, :id => user_id)
      render_popup :title => t(:vote_title)
    else
      redirect_to_with_notice r, profile_path(:action => :index, :id => user_id)
    end

  end

end

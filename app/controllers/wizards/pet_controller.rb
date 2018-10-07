class Wizards::PetController < WizardsController

  def index
    u = current_user
    @user = u
    if @user.has_pet?
      @max_value = [ u.pet_power, u.pet_protection, u.pet_dexterity, u.pet_skill, u.pet_weight ].max
      @prices = {
        :pet_power => UserAttributesGrowthTable.get_power_price(u, true),
        :pet_protection => UserAttributesGrowthTable.get_protection_price(u, true),
        :pet_dexterity => UserAttributesGrowthTable.get_dexterity_price(u, true),
        :pet_skill => UserAttributesGrowthTable.get_skill_price(u, true),
        :pet_weight => UserAttributesGrowthTable.get_weight_price(u, true)
      }
      @power_ups      = AllGameItems::PET_POWERUPS
      @pet_potions    = @user.available_pet_items
      @pet_power_used = AllGameItems::PET_POWER.is_active?(@user) ? AllGameItems::PET_POWER.get_power(@user, @user.pet_power) : 0
    end
  end

  def use
    user = current_user
    item = AllUserItems.find_by_key params[:item]
    r = ProfileRules.can_use_item(user, item)
    if r.allow?
      item.use(user)
      user.save!

      redirect_to_with_notice({:info => t(:you_used_item, :name => item.title)}, pet_path)
    else
      redirect_to_with_notice r, pet_path
    end
  end

  def process_buy
    user = current_user
    buy_pet params[:pet_kind] || user.pet_kind || User::PET_1
  end

  def activate
    user = current_user
    Services::PetService.set_pet_lock user do
      value = params[:value] != 'f'
      r = PetRules.can_activate(user, value)
      if r.allow?
        Services::PetService.activate_pet user, value
      else
        redirect_to_with_notice r, :action => :index
      end
    end
    redirect_to :action => :index
  end

  def process_train
    u = current_user
    attribute = params[:a]
    r = PetRules.can_train_attribute(u, attribute)
    if r.allow?
      Services::PetService.set_pet_lock u do
        price = UserAttributesGrowthTable.get_price(u, attribute.intern, true)

        u.spend_money(price, "pet_train", attribute)
        u['pet_' + attribute] += 1
        u.save!
      end

      redirect_to :action => :index
    else
      redirect_to_with_notice r, :action => :index
    end
  end

  #  # the same as profile use
  #  def use
  #    user = current_user
  #    key = params[:item]
  #    item = user.get_item_by_key(key)
  #    r = Rules::Profile.can_use_item(user, item)
  #    if r.allow?
  #      item.use!(user)
  #      redirect_to :action => :index
  #    else
  #      redirect_to_with_notice r, :action => :index
  #    end
  #  end
  #
  #  # the same as profile takeoff
  #  def takeoff
  #    user = current_user
  #    key = params[:item]
  #    item = user.get_item_by_key(key)
  #    if item
  #      r = Rules::Profile.can_takeoff_item(user, item)
  #      if r.allow?
  #        item.takeoff(user)
  #      else
  #        redirect_to_with_notice r, :action => :index
  #      end
  #    end
  #    redirect_to :action => :index
  #  end
  #
  #  # the same as house extend
  #  def extend_item
  #    do_extend_item current_user, params[:item]
  #    redirect_to_with_notice flash[:notice], :action => :index
  #  end

  private

  def buy_pet(kind)
    user = current_user

    Services::PetService.set_pet_lock user do

      r = PetRules.can_buy(user, kind)
      if r.allow?
        action = user.has_pet? ? "reanimate_pet" : "buy_pet"

        price = Price.new(user, 0, user.has_pet? ? GameProperties::PET_REANIMATE_PRICE_STAFF :
            GameProperties::PET_BUY_PRICE_STAFF, 0, action)
        price.pay(false, "item_pet")

        user.pet_kind = kind
        user.pet_health = user.max_pet_health
        user.pet_active = false
        user.save!
      else
        redirect_to_with_notice r, :action => :index
      end
    end
    redirect_to :action => :index
  end

end

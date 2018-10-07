class Wizards::ShopController < WizardsController

  def index
    @user = current_user
    @category = params[:category]
    
    if @category.blank?
      redirect_to :action => :power_up
      return
    end

    items = AllUserItems.find_by_category_and_level @category, @user.a_level

    @items = WillPaginate::Collection.create(page || 1, 7, items.size) do |pager|
      pager.replace items[pager.offset, pager.per_page]
    end

  end

  def buy
    user = current_user
    item = AllUserItems.find_by_key params[:item]

    r = ShopRules.can_buy_item(user, item)
    if r.allow?
      item.buy user
      user.save!

      user.done_task!(TutorialShop::NAME, :item_key => item.key)
      
      notice = { :info => t(:buy_notice, :name => item.title)}
    else
      notice = r.message
    end
    redirect_to_with_notice notice, :action => :index, :category => item ? item.category : nil, :page => params[:page]
  end

  def sell
    user = current_user
    item = AllUserItems.find_by_key params[:item]

    r = ShopRules.can_sell_item(user, item)
    if r.allow?
      item.sell user
      user.save!
      notice = {:info => t(:sell_notice, :name => item.title)}
    else
      notice = r.message
    end

    redirect_to_with_notice notice, :action => :index, :category => item ? item.category : nil, :page => params[:page]
  end

  def power_up
    @user = current_user
  end

  def extend
    user = current_user
    item = AllUserItems.find_by_key params[:item]

    r = ShopRules.can_extend_item(user, item)
    if r.allow?
      item.extend user
      user.save!

      notice = {:info => t(:extend_notice, :name => item.title)}
    else
      notice = r.message
    end

    redirect_to_with_notice notice, :action => :index, :category => item ? item.category : nil
  end

  def extend_powerup
    user = current_user
    item = AllGameItems.get params[:g]

    r = ProfileRules.can_extend user, item
    if r.allow?
      item.extend user
      user.save!

      user.done_task!(TutorialPowerups::NAME)
      
      notice = {:info => t(:you_extended_item, {:name => item.title})}
    else
      notice = r.message
    end
    redirect_to_with_notice notice, :action => :power_up
  end
  
end

class Wizards::RespectController < WizardsController

  def index
    @order  = params[:order_best]
    @name   = params[:name]
    @name = "" if @name.nil?

    filter = {:name => @name}
    
    case @order
    when "m"
      sort = "s_loot_money DESC, a_reputation DESC"
    when "l"
      sort = "a_level DESC, a_experience DESC"
    when "d"
      sort = "s_total_damage DESC, a_reputation DESC"
    when "gf"
      filter[:gender] = "f"
      sort = User::BEST_ORDER
    when "gm"
      filter[:gender] = "m"
      sort = User::BEST_ORDER
    when "o"
      filter[:online] = true
      sort = User::BEST_ORDER
    when "dr"
      sort = "g_achivement_dragons DESC"
    else 
      @order = 'f'
      sort = User::BEST_ORDER
    end
    
    @user = User.find_the_best_users(filter, sort, page, 30 * 5, 30)
    if @user.size == 0 && !@name.blank?
      flash[:notice] = t(:user_with_name_empty, :name => @name)
    end
  end

  def clans
    @order  = params[:order_best]
    @name   = params[:name]
    @name = "" if @name.nil?
    case @order
    when "n"
      sort = "name DESC"
    else
      @order = 'f'
      sort = Clan::BEST_ORDER
    end
    
    @clans = Clan.find_the_best_clans({:clan_name => @name}, sort, page, 30 * 5, 30)

    if @clans.size == 0 && !@name.blank?
      flash[:notice] = t(:clan_with_name_empty, :name => @name)
    end
  end

  def vote
    @users = User.find_top_voting(page, 30 * 5, 30)
  end

end

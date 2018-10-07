class Wizards::GamesController < WizardsController

  def index
    redirect_to home_path(:action => :index_ajax)
    return


    
    #DEPRECATED
    @category = params[:category]
    @categories = ExternalGames.categories

    if @category.blank?
      items = ExternalGames.get_games
    else
      items = ExternalGames.get_by_category(@category)
    end

    @kongregate_games = WillPaginate::Collection.create(page || 1, 21, items.size) do |pager|
       pager.replace items[pager.offset, pager.per_page]
    end

    id = params[:id]
    unless id.blank?
      @game = ExternalGames.get(id)
      current_user.done_task!(TutorialPlaygame::NAME)
    end
  end

end

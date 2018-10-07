class Wizards::HomeController < WizardsController

  include Wizards::HomeExt::Meditation
  include Wizards::HomeExt::Dailybonus
  include Wizards::HomeExt::Tutorials

  before_filter :render_index_extentions, :only => [:index, :index_ajax]
  
  def index
    #not need auto close pop up
    cookies[:cd] = 'false'
    @callback_url = params[:callback].blank? ? "/#{self.controller_name}" : params[:callback]
    @user = current_user
    render_partial :index
  end

  def index_ajax
    render_content :index
  end

  protected

  def render_index_extentions
    render_meditation
    render_daily_bonus
    populate_task

    @current_dragon = Dragon.current
    @last_planner   = Dragon.last_planned
    @active_dragon  = !@current_dragon.nil? && @current_dragon.active?
  end
  
end
class Admin::NewsController < AdminController

  def index
    @messages = NewsMessage.all_news params[:page]
  end

  def show
    @message = NewsMessage.find(params[:id])
  end

  def new
    @message = NewsMessage.new
    @message.position = 5
  end

  def edit
    @message = NewsMessage.find(params[:id])
  end

  def create
    @message = NewsMessage.new(params[:news_message])
    if @message.save
      redirect_to admin_news_url(@message)
    else
      render :action => 'new'
    end
  end

  def update
    @message = NewsMessage.find(params[:id])
    if @message.update_attributes(params[:news_message])
      redirect_to admin_news_url(@message)
    else
      render :action => "edit"
    end
  end

  def destroy
    @message = NewsMessage.find(params[:id])
    @message.destroy

    redirect_to admin_news_index_url
  end

end

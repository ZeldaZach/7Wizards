class Wizards::BuygoldController < WizardsController
  def index
    @user = current_user
    @success = params[:success]
    @products = [{:key =>"g1",:description => "$ 5.99",  :gold => 600},
      {:key =>"g2",:description => "$ 17.99", :gold => 2400},
      {:key =>"g3",:description => "$ 35.99", :gold => 5400}]

  end

  def payments_log
    @user = current_user
    @payments = PaymentLog.user_payments(@user, page)
  end

  def buy_warning
    render_popup :title => "Warning"
  end

  def success
  end

  def do_buy_hi5
    gold = params[:gold]
    
    if gold.to_i < 1
      redirect_to_with_notice(t(:incorrect_gold_value), :action => :index)
      return
    end

    id = hi5_buy_gold(fbsession, (GameProperties::HI5_EXCHANGE * gold.to_i).to_s, "buy #{gold}")

    id = id.first if id.is_a?(Array)

    if id && id.to_i > 0
      current_user.add_staff!(gold.to_i, "buy_gold", "hi5.buy_gold", PaymentLog::BUY_STAFF)
      redirect_to buygold_path(:action => :index)
      return
    else
      redirect_to_with_notice(t(:not_enought_coins), buygold_path(:actoin=> :index))
    end
  end
end

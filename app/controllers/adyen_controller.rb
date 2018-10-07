class AdyenController < ActionController::Base

  def index
  end

  def notify

    @notification = Adyen::Notification::HttpPost.log(request)

    if @notification.success?
      case @notification.event_code
      when 'AUTHORISATION'
        # A payment authorized successfully, so handle the payment
        # ...
        # flag the notification so we know that it has been processed

        adjust_payment
      when 'RECURRING_CONTRACT'
        # Handle a new recurring contract
        # ...
        adjust_payment
      end
    else
      result = @notification.merchant_reference.split("-")
      user = User.find_by_id(result[1])

      if !result.nil? && user
        product = AdyenConfig.get_by_key(result[0])
        Message.send_buy_gold_refused(user, product["gold"])
        Notifier.deliver_payment_refused(user)
      end
    end

  rescue ActiveRecord::RecordInvalid => e
    # Validation failed, because of the duplicate check.
    # So ignore this notification, it is already stored and handled.
  ensure
    # Always return that we have accepted the notification
    render :text => '[accepted]'

  end

  def adjust_payment
    result = @notification.merchant_reference.split("-")
    user = User.find_by_id(result[1])
    
    if !result.nil? && user
      product = AdyenConfig.get_by_key(result[0])
      staff = product["gold"].to_i
      
      @notification.update_attributes({:processed => true, :user_id => user.id, :staff => staff})

      user.add_staff!(staff, "buy_gold", "adyen.buy_gold", PaymentLog::BUY_STAFF, @notification.value)

      Message.send_buy_gold_processed(user, staff)
      Notifier.deliver_payment_successful(user)
    end
  end

end 
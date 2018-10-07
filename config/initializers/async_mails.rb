# Adds :async_smtp and :async_sendmail delivery methods
# to perform email deliveries asynchronously
module AsynchronousMailer
  %w(smtp sendmail).each do |type|
    define_method("perform_delivery_async_#{type}") do |mail|
      if GameProperties::PROD
        Thread.start do
          begin
            send "perform_delivery_#{type}", mail
          rescue Exception => e
            ExceptionNotifier.deliver_background_exception_notification(e)
          end
        end
      else
        send "perform_delivery_#{type}", mail
      end
    end
  end
end

ActionMailer::Base.send :include, AsynchronousMailer

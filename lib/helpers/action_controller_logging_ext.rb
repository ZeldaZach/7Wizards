module Helpers::ActionControllerLoggingExt
  def self.included(base)
    base.class_eval do
      alias_method_chain :perform_action, :log_session
    end
  end

  def perform_action_with_log_session
    if logger && logger.info? && !session[:user].blank?
      logger.info "  User Id: #{session[:user]}"
    end
    perform_action_without_log_session
  end
end

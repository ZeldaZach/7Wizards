module ActionController
  class CgiRequest
#    def session
#      unless defined?(@session)
#        if @session_options == false
#          @session = Hash.new
#        else
#          stale_session_check! do
#            if cookie_only? && query_parameters[session_options_with_string_keys['session_key']]
#              raise SessionFixationAttempt
#            end
#            case value = session_options_with_string_keys['new_session']
#              when true
#                @session = new_session
#              when false
#              begin
#                @session = CGI::Session.new(@cgi, session_options_with_string_keys, query_parameters[session_options_with_string_keys['session_key']])
#                # CGI::Session raises ArgumentError if 'new_session' == false
#                # and no session cookie or query param is present.
#                rescue ArgumentError
#                @session = Hash.new
#              end
#              when nil
#                @session = CGI::Session.new(@cgi, session_options_with_string_keys, query_parameters[session_options_with_string_keys['session_key']])
#              else
#                raise ArgumentError, "Invalid new_session option: #{value}"
#            end
#            @session['__valid_session']
#          end
#        end
#      end
#      @session
#    end
  end
end
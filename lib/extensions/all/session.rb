class ::CGI #:nodoc:
  class Session #:nodoc:

#    alias_method :initialize_without_uri_session_key, :initialize
#
#    def initialize(cgi, options = {}, session_id=nil)
#      key = options['session_key']
#
#      if cgi.cookies[key].empty?
#        if !session_id
#          query = ENV['RAW_POST_DATA'] || cgi.query_string || ''
#          session_id = CGI.parse(query)[key].first if cgi.cookies[key].empty?
#        end
#        if session_id
#          cgi.params[key] = session_id
#          options['session_id'] = cgi.params[key]
#        end
#      end
#
#      @cgi = cgi
#
#      initialize_without_uri_session_key(cgi, options)
#    end
    
  end
end
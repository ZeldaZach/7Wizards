#DEPRECATED 
module ApplicationExt
  module History

    MAX_HISTORY = 5
    
    def push_history(url)
      history = session[:history] || []
      if url != history.last && params[:sh].blank?
        history.delete(history.first) if history_count >= MAX_HISTORY
        history.push url
        session[:history] = history
      end
    end

    def pop_history
      history = session[:history] || []

      u = history.pop
      u = history.last || "/"

      session[:history] = history

      v = "sh=true"
      if m = u.match(/sh=(\w*)/)
        u = u.gsub(m[0], v)
      else
        u += u.include?('?') ? '&' : '?'
        u += v
      end
      u
    end

    def history_count
      session[:history].nil? ? 0 : session[:history].length
    end
    
  end
end

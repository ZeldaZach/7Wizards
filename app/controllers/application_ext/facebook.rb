module ApplicationExt
  module Facebook

    def get_facebook_cookie
      fb_cookies = cookies["fbs_#{FacebookConfig.facebook_app_id}"]
      
      return if fb_cookies.blank?
      
      fb_cookies = fb_cookies.gsub('"', '')
      fb_params  = CGI::parse(fb_cookies)
      
      payload = ""
      session[:fbc_sesssion] = {}
      fb_params.sort.each do |key, value|

        session[:fbc_sesssion][key] = value.is_a?(Array) ? value.first : value

        payload << "#{key}=#{session[:fbc_sesssion][key]}" if key != 'sig'
      end

      if session[:fbc_sesssion]['sig'] == Digest::MD5.hexdigest("#{payload}#{FacebookConfig.facebook_secret}")
        return session[:fbc_sesssion]
      end
      nil
    end

    def facebook_user_info
      return unless session[:fbc_sesssion]
      begin
        MiniFB.call(FacebookConfig.facebook_app_id, FacebookConfig.facebook_secret, "Users.getInfo", "session_key" => session[:fbc_sesssion]["session_key"], "uids" =>session[:fbc_sesssion]["uid"], "fields" => MiniFB::User.standard_fields)
      rescue
        clear_facebook_cookie
      end
    end

    def clear_facebook_cookie
      
      session[:fbc_sesssion] = nil 
      cookies["fbs_#{FacebookConfig.facebook_app_id}"] = nil
    end

    def facebook_connect_publish(title, image_url)
      MiniFB.rest(session[:fbc_sesssion]["access_token"], "stream.publish", :params => {
          :uid => session[:fbc_sesssion]["uid"],
          :message => "",
          :attachment => {:caption => "7wizards", :description => title, :media => [{:type => "image", :src => "#{GameProperties::PRODUCTION_HOST}#{image_url}", :href => "#{GameProperties::PRODUCTION_HOST}/"}]}.to_json
        })
    end

  end
end

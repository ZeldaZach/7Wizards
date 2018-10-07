module Helpers
  module WizardsHelper

    def wizards_javascript

      js = ""
      observe_js = "wizards.init({ajax_mode:#{GameProperties.is_enabled_mode?(:ajax)}, user_id:#{current_user.id}, partner_url:'#{partner_url}'}); "

      unless current_user.confirmed_email
        
        #show pop up with selection name and gender
        if current_user.bigpoint?
          
          js << "navigate('#{bigpoint_path(:action => :bigpoint_confirm)}');"
          
          #show pop up for change name if used name already registered
        elsif current_user.hi5? || current_user.facebook?
          js << "navigate('#{wizards_path(:action => :change_name)}');"
        else
          if current_user.is_new_user
            observe_js << "navigate('#{wizards_path(:action => :welcom)}');"
          end
        end
      end

      #inform user about new messages
      js << new_messages
      js << achivement_notify
      js << "Element.observe(window, 'load', function(){#{observe_js}});"
      
      javascript_tag js
    end

    def new_messages
      "wizards.show_new_messages(#{current_user.has_unread_mails?});"
    end

    #show achivement pop up
    def achivement_notify
      AbstractAchivement.get_new_achivement(current_user).nil? ? "" :
        " wizards.onScrollTop(); navigate('#{wizards_path(:action => :achivement_notify)}');"
    end


    def analithic_javascript(callback = nil)
      
      track = callback.nil? ? "['_trackPageview']" : "['_trackPageview', '#{callback}']"
      
      ga = <<-GOOGLE
      var _gaq = _gaq || [];
      _gaq.push(['_setAccount', 'UA-17359215-1']);
      _gaq.push(['_setDomainName', '.7wizards.com']);
      _gaq.push(['_setCampNameKey', 'cid']);
      _gaq.push(['_setCampSourceKey', 'src']);
      _gaq.push(['_setCampTermKey', 'kw']);
      _gaq.push(#{track});

      (function() {
        try {

          var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
          ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
          var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
        } catch(e) {}
      })();
      GOOGLE

      javascript_tag ga
    end

  end
end

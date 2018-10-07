module Wizards
  module Ext
    module Fight

      def render_fight_result(options)
        if @is_flash
          render_json options
        else
          if options[:success]
            options[:user] ||= @user
            options[:drid] ||= double_request_id
            render_content :fight_result, :destination => "results_without_flash", 
              :locals => options
          else
            redirect_to_with_notice(options[:message], options[:url])
          end
        end
      end

      def fight_result
        @user = current_user
        @user.adjust_attributes(true)
        @fight_log = FightLog.find_by_id(params[:id])
        r  = FightRules.can_see_fight_log(@user, @fight_log)
        if !r.allow?
          redirect_to :action => :index
          return
        end
        options = {}
        options[:success] = true
        options[:log] = @fight_log
        render_fight_result(options)
      end

    end
  end
end

module Wizards
  module HomeExt
    module Meditation
      
      def render_meditation
        @user = current_user
        
        @meditate_max_time = GameProperties::MEDITATION_MAX_TIME
        @meditate_times_to_go = GameProperties::MEDITATION_TIMES_TO_GO

        if(@user.meditating?)
          @receive_money = @user.meditation_money
        end
      end

      def cancel_meditation
        user = current_user
        r = HomeRules.can_cancel_meditate(user)
        if r.allow?
          user.meditation_started_at = nil
          user.meditation_finished_at = nil
          user.meditation_experience = nil
          user.meditation_money = nil
          user.save!
        else
          flash[:notice] = r.message
        end
        render_meditation
        render_content :meditation, {:destination => :meditation_content}
      end

      def process_meditation
        user = current_user

        if params[:time].blank?
          redirect_to home_url
          return
        end

        time = params[:time].to_i

        r = HomeRules.can_meditate(user, time)
        if r.allow?

          user.meditation_started_at = Time.now
          user.meditation_finished_at = user.meditation_started_at + time # ( skorohod ? GameProperties::MEDITATION_SKOROHOD_TIME : time )

          times_per_ten_mins = (time.seconds_to_minutes / 10).to_i

          meditation_money = times_per_ten_mins *  MeditationGrowthTable.get_current_money(user)
          user.meditation_money = meditation_money
          
          possibility_percent = time.to_f / GameProperties::MEDITATION_MAX_TIME
          if rand <= possibility_percent
            user.meditation_experience = GameProperties::MEDITATION_EXPERIENCE
          end

          user.register_activity('meditation')

          user.save!

          user.done_task!(TutorialMeditation::NAME)
          
        else
          flash[:notice] = r.message
        end
        render_meditation
        render_content :meditation, {:destination => :meditation_content}
      end
    end
  end
end

module Wizards
  module HomeExt
    module Dailybonus

      def render_daily_bonus
        user = current_user
        r = BonusRules.cat_get_bonus(user)
        if !r.allow?
          @bonus_description = r.message
        end
      end

      def get_bonus
        user = current_user
        r = BonusRules.cat_get_bonus(user)

        if r.allow?
          if rand <= GameProperties::DAILY_BONUS_POSSIBILITY_GET_HIGH || !user.is_done_task(TutorialDailybonus::NAME)
            max = GameProperties::DAILY_BONUS_HIGHT[1]
            min = GameProperties::DAILY_BONUS_HIGHT[0]
          else
            max = GameProperties::DAILY_BONUS_LOW[1]
            min = GameProperties::DAILY_BONUS_LOW[0]
          end
          
          gold = rand(max - min) + min
          
          user.add_staff!(gold, "daily_bonus", "home.bonus")

          @bonus_description = t(:you_receive_staff_bonus, :count => gold)
          user.daily_bonus_updated_at = Time.new
          user.save!

          user.done_task!(TutorialDailybonus::NAME)

          Message.send_bonus_message(user, 0, gold, t(:daily_bonus_reason), t(:daily_bonus))
        else
          flash[:notice] = r.message
        end
        render_content :dailybonus, {:destination => :dailybonus_content}
      end
    end
  end
end
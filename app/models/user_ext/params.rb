module UserExt
  module Params

    def a_money # TODO we should write extension to support such cases
      m = self[:a_money]
      m && m > 0 ? m : 0
    end

    def a_money=(value)
      self[:a_money] = [value, 0].max
    end
    
#gold can be as minus value, when user refund payment
#    def a_staff
#      m = self[:a_staff]
#      m && m > 0 ? m : 0
#    end

#    def a_staff=(value)
#      if minus
#        self[:a_staff] = value
#      else
#        self[:a_staff] = [value, 0].max
#      end
#    end

    def a_staff2
      m = self[:a_staff2]
      m && m > 0 ? m : 0
    end

    def a_staff2=(value)
      self[:a_staff2] = [value, 0].max
    end

    def admin?
      is_admin
    end

    def moderator?
      is_moderator
    end

    def user_id
      id
    end

    def female?
      self.gender == "f"
    end

    def male?
      !female?
    end

    def virtual?
      false # should be true in case of dragon && monster in quest
    end

    def monster?
      !self.monster_kind.nil?
    end

    def dragon?
      false
    end

    def meditating?
      self.meditation_started_at && self.meditation_finished_at && self.meditation_finished_at > Time.now
    end

    def on_holiday?
      # if user was active more then 5 days then it's on holidays
      return true if self.last_activity_time && self.last_activity_time < GameProperties::USER_HOLIDAY_TIME.ago
      # if user executed go on holiday action and holiday is still in progress
      self.on_holiday
    end

    def holiday_is_active?
      self.holiday_start_time && self.holiday_start_time > GameProperties::USER_HOLIDAY_MIN_DURATION.ago
    end

    def holiday_end_time
      self.holiday_start_time + GameProperties::USER_HOLIDAY_MIN_DURATION
    end

    def max_health
      HealthGrowthTable.get_max_health(self, false)
    end

    def health_hour_regeneration
      HealthGrowthTable.get_hour_regeneration(self, false)
    end

    def next_level_experience
      ExperienceGrowthTable.get_next_level_experience(self)
    end

    def max_fights_count
      GameEnduranceItem.get_max_fights_count self
    end

    # will return time in seconds when new fight will be added
    def remaining_fight_regenerate_time
      GameEnduranceItem.get_remaining_fight_regenerate_time self
    end

    def regeneration_time_per_fight
      GameEnduranceItem.get_fight_regeneration_time(self)
    end

    def fight_price
      [GameProperties::FIGHT_FIND_PRICE, self.a_level].max
    end

    def partner_url
      UserMarketingInfo.get_referrer_host(self)
    end

    def users_count_on_level
      User.count :conditions => {:a_level => self.a_level}
    end

    def has_unread_mails?
      Message.has_unread_messages?(self) || ClanMessage.unread_history_count(self) > 0
    end

    #user has registered 2 minutes ago
    def is_new_user
      self.created_at > 2.minutes.ago
    end

    def get_last_achivement
      AbstractAchivement.get_new_achivement(self)
    end

    def can_receive_bonus_for_kill_pet?(opponent)
      self.has_pet? && opponent.has_pet? && self.a_level - opponent.a_level <= GameProperties::FIGHT_PET_LEVEL_DIFF
    end

    def votes_count
      AvatarVoting.votes_count(self)
    end

    def created_days
      (Time.now - self.created_at).seconds_to_days
    end

    def self.included(klass)
      klass.extend ClassMethods
    end

    module ClassMethods
      
      def add_holiday_conditions(conditions)
        conditions[0] += " and last_activity_time > ? and on_holiday = ?"
        conditions << GameProperties::USER_HOLIDAY_TIME.ago
        conditions << false
        conditions
      end
    end
    
  end
end

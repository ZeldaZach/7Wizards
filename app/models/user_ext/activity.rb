module UserExt
  module Activity

    ACTIVITY_LOGOUT = 'logout'

    ACTIVE_USERS_CONDITION_QUERY = 'last_activity != ? and last_activity_time > ?'
    ACTIVE_USERS_ORDER = 'last_activity desc'

    ACTIVE_CHAT_USERS_CONDITION_QUERY = 'chat_activity_time > ?'

    def is_online?
      self.last_activity && 
        !self.last_activity != ACTIVITY_LOGOUT &&
        self.last_activity_time > GameProperties::USER_ACTIVE_PERIOD.ago
    end

    def is_chat_online?
      self.chat_activity_time && self.chat_activity_time > GameProperties::USER_ACTIVE_PERIOD.ago
    end

    #on logout not need validate password
    def activity_logout!
      register_activity! ACTIVITY_LOGOUT, false
    end

    def register_activity(name)
      self.last_activity = name
      self.last_activity_time = Time.now
    end

    def register_activity!(name, perform_validation = true)
      register_activity name
      perform_validation ? save! : save(false)
    end

    def register_chat_activity
      self.chat_activity_time = Time.new
    end

    def register_chat_activity!
      self.register_chat_activity
      self.save!
    end


    def self.included(klass)
      klass.extend ClassMethods
    end

    module ClassMethods
      # class methods here

      def apply_active_conditions(conditions = [])
        if conditions.blank?
          conditions = [ACTIVE_USERS_CONDITION_QUERY]
        else
          conditions[0] += ' and (' + ACTIVE_USERS_CONDITION_QUERY + ')'
        end
        conditions << ACTIVITY_LOGOUT
        conditions << GameProperties::USER_ACTIVE_PERIOD.ago
        conditions
      end

      def active_users(page = 1)
        conditions = User.apply_active_conditions
        User.paginate :conditions => conditions, :order => ACTIVE_USERS_ORDER, :page => page
      end

      def active_users_count
        conditions = User.apply_active_conditions
        User.count :conditions => conditions
      end

    end
  end
end

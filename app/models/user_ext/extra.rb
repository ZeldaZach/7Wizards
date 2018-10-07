# we store different extra attributes into redis
# all redis related user attributes are handled in this module

module UserExt
  module Extra

    # we support dynamic extra attributes. you can write something like this:
    # e_my_custom_attr = 10 and it will be stored into extra under my_custom_attr value
    def self.included(base)
      base.class_eval do
        alias_method_chain :method_missing, :extra_param
      end
    end

    def e_get(name, default = nil)
      extra_obj[name.to_sym] || default
    end

    def e_set(name, value)
      extra_obj[name.to_sym] = value
      @extra_ctanged = true
    end

    def e_save!()
      return if !@extra_obj || !@extra_ctanged
      RedisCache.put "user_#{id}_extra", @extra_obj
      @extra_ctanged = false
    end
    
    # register fight with user
    def e_register_fight(fight_log)
      fights = e_get :fights, []
      fights_new = fights.select do |fight|
        fight[:t] && fight[:t] >= 1.day.ago
      end      
      fights_new << {
        :fid => fight_log.id,
        :uid => fight_log.user_id,
        :oid => fight_log.opponent_id,
        :t => fight_log.created_at
      }
      e_set :fights, fights_new

      # in addition to fights history we should also store
      # each staff2 lose action
      if fight_log.loser == self && fight_log.winner_staff2_diff > 0
        lost_staff2 = e_get :lost_staff2, []
        lost_staff2_new = lost_staff2.select do |value|
          value[:t] && value[:t] >= 1.day.ago
        end
        lost_staff2_new << {
          :a => fight_log.winner_staff2_diff,
          :oid => fight_log.winner.id,
          :t => fight_log.created_at
        }
        e_set :lost_staff2, lost_staff2_new
      end

      if fight_log.loser == self
        time_now = Time.new
        if fight_log.winner_experience > 0
          e_set :last_give_experience, time_now
        end

        if fight_log.winner_reputation > 0
          e_set :last_give_reputation, time_now
        end

        if fight_log.receive_max_money_percent
          e_set :last_give_hight_money, time_now
        end
      end

      e_save! # TODO seems incorrect, should be checked and optimized, seems we should not save here !!!
    end

    def e_last_give_hight_percent_money
      e_get :last_give_hight_money
    end

    def e_last_give_experience
      e_get :last_give_experience
    end

    def e_last_give_reputation
      e_get :last_give_reputation
    end

    # will return time when current user attacked opponent last time during one day
    def e_get_last_user_attack_time(opponent_id)
      fights = e_get :fights, []
      fights.reverse_each do |fight|
        return fight[:t] if fight[:oid] == opponent_id
      end
      nil
    end

    # will return amount of fights with user per day
    def e_get_user_attacks_count(opponent_id, time = nil)
      result = 0
      fights = e_get :fights, []
      fights.each do |fight|
        t = fight[:t]
        if fight[:oid] == opponent_id && ( time.nil? || (t && t >= time ))
          result += 1
        end
      end
      result
    end

    #return fights count per day
    def e_get_user_fights_count(time = nil)
      result = 0
      fights = e_get :fights, []
      fights.each do |fight|
        t = fight[:t]
        if fight[:uid] == self.id && ( time.nil? || (t && t >= time ))
          result += 1
        end
      end
      result
    end

    def e_create_remove_chat_room(options, add = true)
      user_rooms_key = "user_#{id}_chat_rooms"
      user_has_room  = false
      user_rooms     = e_get_chat_rooms

      user_rooms.each do |room|
        if room[:key] == options[:key]
          options = room
          user_has_room = true 
          break
        end
      end
      
      user_rooms << options unless user_has_room && add
      user_rooms -= [options] if user_has_room && !add
      
      RedisCache.put user_rooms_key, user_rooms, 5.days
    end

    def e_get_chat_rooms
      RedisCache.get("user_#{id}_chat_rooms", [])
    end

    def e_register_chat_report(user)
      RedisCache.put "chat_report_#{id}_#{user.id}", Time.now, GameProperties::CHAT_REPORT_RESTRICTION_TIME
    end

    def e_get_chat_report(user)
      RedisCache.get "chat_report_#{id}_#{user.id}"
    end

    #    def e_fights_won
    #      #TODO should implement or move
    #      0
    #    end
    #
    #    def e_money_won
    #      #TODO should implement or move
    #      0
    #    end
    #
    #    def e_money_lost
    #      #TODO should implement or move
    #      0
    #    end

    # will return amount of attacks to user
    def e_attacks_count(time = nil)
      e_get_user_attacks_count self.id, time
    end

    # will return true if current user won staff from opponent
    def e_user_lost_staff2?(opponent_id)
      lost_staff2 = e_get :lost_staff2, []
      lost_staff2.each do |value|
        t = value[:t]
        return true if value[:oid] == opponent_id && t && t >= GameProperties::FIGHT_STAFF2_DURATION_BETWEEN_RECEIVE.ago
      end
      false
    end

    # will return amount of lost staff2
    def e_user_lost_staff2_count
      lost_staff2 = e_get :lost_staff2, []
      lost_staff2.length
    end

    # will update potion usage record
    def e_use_potion!(key)
      last_use = e_get :potion_usage, {}
      last_use[key] = Time.now
      e_set :potion_usage, last_use
      
      e_save!
    end

    def e_get_last_potion_usage(key)
      last_use = e_get :potion_usage, {}
      last_use[key]
    end

    private
    
    def extra_obj
      if !@extra_obj
        @extra_obj = RedisCache.get("user_#{id}_extra", {})
      end
      @extra_obj
    end

    def method_missing_with_extra_param(method, *args)
    
      m = method.to_s

      # did somebody tried to paginate? if not, let them be
      unless m.index('e_') == 0
        if block_given?
          return method_missing_without_extra_param(method, *args) { |*a| yield(*a) }
        else
          return method_missing_without_extra_param(method, *args)
        end
      end

      m.slice! 'e_'
      value = args.pop

      if m.ends_with? '='
        m = m.gsub /\=$/, ''
        e_set m, value
      else
        e_get m, value
      end
    end

  end
end

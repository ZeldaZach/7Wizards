#class MessageExt::Event < Message

#  def self.user_events(user, page = 1)
#    Message.paginate :conditions => ['user_id in (?, ?) and kind in (?)', user.id, ALL_USERS,
#      Message::EVENTS], :page => page
#  end
#
#  def self.create_fight_try(user, opponent)
#    Message.create! :user => opponent,
#      :title => t(:fight_try, { :id => user.id, :name => user.name } ),
#      :kind => FIGHT_TRY
#  end
#
#  def self.create_fight(fight_log)
#
#    user_is_monster = fight_log.user_a.monster? || fight_log.user_a.dragon?
#    opponent_is_monster = fight_log.opponent_a.monster? || fight_log.opponent_a.dragon?
#
#    if fight_log.user_won
#
#      options_u = {
#        :id => fight_log.opponent.id,
#        :name => h(fight_log.opponent.name),
#        :money => fight_log.winner_money_diff.abs
#      }
#      key_u = :you_strike_win
#
#      options_o = {
#        :id => fight_log.user.id,
#        :name => h(fight_log.user.name),
#        :money => fight_log.loser_money_diff.abs
#      }
#      key_o = :you_striked_lose
#
#      if fight_log.winner_staff2_diff > 0
#        options_u[:staff2] = fight_log.winner_staff2_diff
#        key_u = :you_strike_win_staff2
#
#        options_o[:staff2] = fight_log.winner_staff2_diff
#        key_o = :you_striked_lose_staff2
#      end
#    else
#      options_u = {
#        :id => fight_log.opponent.id,
#        :name => h(fight_log.opponent.name),
#        :money => fight_log.loser_money_diff.abs
#      }
#      key_u = :you_strike_lose
#
#      options_o = {
#        :id => fight_log.user.id,
#        :name => h(fight_log.user.name),
#        :money => fight_log.winner_money_diff.abs
#      }
#      key_o = :you_striked_win
#
#      if fight_log.winner_staff2_diff > 0
#        options_u[:staff2] = fight_log.winner_staff2_diff
#        key_u = :you_strike_lose_staff2
#
#        options_o[:staff2] = fight_log.winner_staff2_diff
#        key_o = :you_striked_win_staff2
#      end
#    end
#
#    Message.create! :user => fight_log.user,
#      :title => t(key_u, options_u),
#      :kind => FIGHT_USER,
#      :extra => fight_log.user_won ? 'w' : 'l',
#      :detail => fight_log.id if !user_is_monster
#
#    Message.create! :user => fight_log.opponent,
#      :title => t(key_o, options_o),
#      :kind => FIGHT_OPPONENT,
#      :extra => fight_log.user_won ? 'l' : 'w',
#      :detail => fight_log.id if !opponent_is_monster
#
#  end
#
#  def self.create_patrol(user)
#
#    message = ''
#
#    if user.patrol_money > GameProperties::PATROL_RICH_GUY_MONEY_PROC.call(user.a_level)
#      message += t(:patrol_rich_guy)
#    end
#
#    if user.patrol_end_time - user.patrol_start_time == GameProperties::PATROL_SKOROHOD_TIME
#      message += t :patrol_skorohod
#    else
#      message += t :patrol_time, :time => (user.patrol_end_time - user.patrol_start_time).seconds_to_minutes
#    end
#
#    message += ' '
#
#    options = {}
#    options[:money] = user.patrol_money if user.patrol_money > 0
#    options[:staff] = user.patrol_staff if user.patrol_staff > 0
#
#    translate_key = :patrol_money           if user.patrol_money > 0 && user.patrol_staff == 0
#    translate_key = :patrol_staff           if user.patrol_money == 0 && user.patrol_staff > 0
#    translate_key = :patrol_money_and_staff if user.patrol_money > 0 && user.patrol_staff > 0
#    translate_key = :patrol_empty           if user.patrol_money == 0 && user.patrol_staff == 0
#
#    message += t(translate_key, options)
#
#    if user.patrol_experience > 0
#      message += t(:patrol_experience, { :experience => user.patrol_experience })
#    end
#
#    Message.create! :user => user,
#      :title => message,
#      :kind => PATROL
#  end
#
#  def self.create_pet_event(user, activate)
#    Message.create! :user => user,
#      :title => activate ? t(:activate_pet) : t(:deactivate_pet),
#      :kind => activate ? PET_EVENT_ACTIVATE : PET_EVENT_DEACTIVATE
#  end

#end

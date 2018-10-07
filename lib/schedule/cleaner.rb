class Schedule::Cleaner < Schedule::Base

  def self.clean
    clean_users(1.months.ago, 4)
    
    r = 0
    r += clean_sessions 7.days.ago
    r += clean_fight_logs GameProperties::EVENTS_LIVE_TIME.ago
    r += clean_messages 20.days.ago
    r += clean_events 5.days.ago
    r += clean_chat 1.weeks.ago
    r
  end

  private

  def self.clean_sessions(period)
    ActiveRecord::SessionStore::Session.delete_all ['updated_at < ?', period]
  end

  def self.clean_fight_logs(period)
    FightLog.delete_all ['created_at < ?', period]
    Message.delete_all ['created_at < ? and kind in (?)', period, [Message::FIGHT_USER, Message::FIGHT_OPPONENT]]
  end

  def self.clean_messages(period)
    Message.delete_all ['created_at < ? and kind in (?)', period, Message::USER_MESSAGES]
  end

  def self.clean_events(period)
    Message.delete_all ['created_at < ? and kind in (?)', period, Message::EVENTS]
  end

  def self.clean_users(period, level)
    sql =<<-SQL
      DELETE relations FROM relations LEFT JOIN users ON (relations.relative_id = users.id) 
      WHERE users.confirmed_email = false and users.last_activity_time < '#{period}' and users.a_level < #{level}
    SQL
    ActiveRecord::Base.connection.execute(sql)
    
    users = User.find :all, :conditions => ['last_activity_time < ? and confirmed_email = ? and a_level < ?', period, false, level]
    users.each do |user|
      UserAvatarService.delete_user_avatars(user)
      user.destroy
    end
  end

  def self.clean_chat(period)
    Chat.delete_all ['created_at < ?', period]
  end

  self.redefine(self)

end 
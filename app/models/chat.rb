class Chat < ActiveRecord::Base

  include BaseModel
  HISTORY_LIMIT = 40
  #
  FILTER_PUBLIC = 'pb' #public room
  FILTER_SAME   = 'pr' #current room
  FILTER_BOYS   = 'm'  #gender - male
  FILTER_GIRLS  = 'f'  #gender - female
  #
  #  GROUP_ROOM_PUBLIC = 1 #public room, clan room, self main room
  #  GROUP_ROOM_MAIN = 2   #invited to main private rooms
  #  GROUP_PERSONAL = 3    #one to one personal rooms
  
  belongs_to :user
  belongs_to :last_reporter, :class_name => 'User', :foreign_key => 'last_reporter_id'

  def self.last_messages(room)
    find :all, :select => "users.id, users.name, users.gender, users.avatar, users.a_level, chats.message, UNIX_TIMESTAMP(chats.created_at) as time", :joins => "left join users on (users.id = chats.user_id)",
      :conditions => {:room => room}, :order => "chats.id DESC", :limit => HISTORY_LIMIT
  end

  def self.last_chat_users(name, gender)
    conditions = " WHERE name like '%#{name}%'" unless name.blank?
    
    if gender == "f" || gender == "m"
      if conditions.blank?
        conditions = " WHERE "
      else
        conditions += " AND "
      end
      conditions += "gender = '#{gender}'"
    end
    
    sql = <<-SQL
      SELECT id, name, gender, avatar, a_level FROM users #{conditions}
      ORDER BY chat_activity_time DESC LIMIT 10
    SQL
    User.find_by_sql(sql)
  end

  def self.send!(user, message, room)
    c = Chat.new :user => user,
      :message => message,
      :room => room
    c.save!
  end

  #  def self.last_by_user(user)
  #    find :last, :conditions => {:user_id => user.id}
  #  end
  #

  #
  #  def self.active_room_users(room, name = '', gender = '', limit = 20)
  #    conditions = ["active = ? and confirmed_email = ? and chat_room = ?", true, true, room]
  #
  #    unless name.blank?
  #      conditions[0] += " and name like ?"
  #      conditions << "%#{name}%"
  #    end
  #
  #    unless gender.blank?
  #      conditions[0] += " and gender = ?"
  #      conditions << gender
  #    end
  #
  #    User.find :all, :conditions => conditions, :order => "chat_activity_time DESC", :limit => limit
  #  end
  #
  #  def self.create_main_room(owner, relative)
  #    key = owner.chat_main_room_name
  #
  #    chat_room = {
  #      :key => key,
  #      :owner_id => owner.id,
  #      :kind => GROUP_ROOM_MAIN,
  #      :title => t(:main_room_title, :user_name => owner.name)
  #      }
  #
  #    relative.e_create_remove_chat_room(chat_room)
  #
  #    chat_room
  #  end
  #
  #  def self.create_personal_room(owner, relative)
  #    chat_room = {
  #      :key => "#{owner.id}_#{relative.id}",
  #      :owner_id => owner.id,
  #      :relative_id => relative.id,
  #      :kind => GROUP_PERSONAL,
  #      :title => "#{owner.name}-#{relative.name}"
  #      }
  #
  #    owner.e_create_remove_chat_room(chat_room)
  #    relative.e_create_remove_chat_room(chat_room)
  #    chat_room
  #  end
  #
  #  def self.destroy_room(user, name)
  #    user.e_create_remove_chat_room({:key => name}, false)
  #  end

end

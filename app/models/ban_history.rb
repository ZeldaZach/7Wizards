class BanHistory < ActiveRecord::Base

  # include base mode behaviour
  include BaseModel

  belongs_to :user
  belongs_to :banned_by, :class_name => 'User', :foreign_key => 'banned_by_id'

  default_scope :order => 'id desc'

  def self.last_ban(user)
    self.find :first, :conditions => ['user_id = ? and ban = ?', user.id, true]
  end

  def self.active_ban(user)
    ban = self.find :first, :conditions => ['user_id = ?', user.id]
    ban && (ban.ban || ban.only_messages) && (ban.ban_end_date && ban.ban_end_date > Time.now) ? ban : nil
  end

  def self.banned_permanently?(user)
    ban = self.find :first, :conditions => ['user_id = ?', user.id]
    ban && ban.ban && ban.ban_end_date.nil?
  end

  def self.active_changed_since(user, date)
    self.count(:conditions => ['user_id = ? and created_at > ?', user.id, date]) > 0
  end

  def self.activate(user, options = {})
    ban = active_ban(user)

    r = true
    r = ban && ban.ban_end_date && ban.ban_end_date < Time.now if options[:check_end_date]

    only_messages = options[:only_messages]

    if only_messages
      r &&= !user.active_messaging
    else
      r &&= !user.active
    end

    if r
      user.active = true unless only_messages
      user.active_messaging = true if only_messages

      ban = BanHistory.new
      ban.user = user
      ban.ban = false
      ban.only_messages = only_messages
      ban.private_reason = options[:private_reason]

      ban.transaction do
        Message.send_ban_messaging(ban) if only_messages
        ban.save!
        user.save! if options[:save_user]
      end
    end

    r
  end

  def self.activate!(user, options = {})
    o = options.dup
    o[:save_user] = true
    activate(user, o)
  end

#  def self.ban_hack!(user, reason, time = nil)
#    ban = BanHistory.new
#    ban.user = user
#    ban.private_reason = 'auto: ' + reason
#    ban.public_reason = t(:ban_hack)
#    ban.ban = true
#    ban.ban_end_date = Time.now + time if time
#    ban.save
#
#    user.active = false
#    user.save
#  end

  def self.ban!(user, time, options = {})
    ban = BanHistory.new

    ban.user = user
    ban.ban = true

    ban.public_reason  = options[:public_reason]
    ban.private_reason = options[:private_reason]
    ban.banned_by      = options[:banned_by]
    ban.only_messages  = options[:only_messages]

    if ban.ban && time
      ban.ban_end_date = Time.now + time
    else
      ban.ban_end_date = nil
    end

    if ban.only_messages
      unless user.active
        # we can't unban already banned user by posting new only messages ban
        return nil
      end
      user.active_messaging = false

      Message.send_ban_messaging(ban)
    else
      user.active = false
    end

    ban.transaction do
      ban.save!
      user.save!
    end

    ban
  end
  
end

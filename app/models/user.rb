class User < ActiveRecord::Base

  # md5 is needed for pasword generation
  require 'digest/md5'

  # ar deltas is needed for delta changes in number fields
  require 'ar-deltas'

  # include base mode behaviour
  include BaseModel
  include Ext::Validators

  # all associations
  has_many :messages
  has_many :items, :autosave => true, :dependent => :destroy, :class_name => 'UserItem'
  has_many :reasigned_items, :class_name => 'UserItem', :foreign_key => "bought_by_id"
  has_many :bans, :class_name => 'BanHistory'
  has_many :user_avatars
  has_many :user_tasks

  belongs_to :active_avatar, :class_name => 'UserAvatar', :foreign_key => 'active_avatar_id'
  belongs_to :clan

  belongs_to :current_clan_war_user,
    :class_name => 'ClanWarUser',
    :foreign_key => 'current_clan_war_user_id'

  belongs_to :referral, 
    :class_name => 'User',
    :foreign_key => 'referral_id'

  # virtual attributes needed for registration and user creation
  attr_accessor :password, :password_confirmation

  # in memory property, needed for monster support
  attr_accessor :monster_kind, :dragon_kind

  # validators
  validates_uniqueness_of :name, :and => {:deleted => false}
  validates_uniqueness_of :email, :and => {:deleted => false}
  validates_size_of :name, :within => 3..20, :allow_nil => false

  validates_size_of :attacker_message, :within => 3..140, :allow_nil => false
  validates_size_of :description, :within => 0..1000, :allow_nil => true
  
  validates_format_of :name, :with => /^([a-z0-9_\-])+$/i

  validates_format_of :email,
    :with => %r{^(?:[_a-z0-9-]+)(\.[_a-z0-9-]+)*@([a-z0-9-]+)(\.[a-zA-Z0-9\-\.]+)*(\.[a-z]{2,4})$}i
  validates_inclusion_of :gender, :in => %w( m f ) # m - male, f - female
  #  validates_acceptance_of :eula

  delta_attributes :a_money, :a_staff, :a_staff2
  delta_attributes :s_referral_bonus_count

  # all named scopes are defined here
  named_scope :active, :conditions => ['active = ? and on_holiday = ? and deleted = ?', true, false, false]
  named_scope :user_order, lambda { |order| { :order => order } }
  named_scope :user_name, lambda  { |name| { :conditions => ["name like ?", "%#{name}%"]} }

  include UserExt::Rating
  include UserExt::Activity
  include UserExt::Params
  include UserExt::Extra
  include UserExt::Items
  include UserExt::Pet
  include UserExt::Clan
  include UserExt::ClanWar
  include UserExt::ClanUnion
  include UserExt::Adjust
  include UserExt::UserAvatars
  include UserExt::Relations
  include UserExt::Chat
  include UserExt::Payment
  include UserExt::Tasks
  include UserExt::Integrations

  # public class methods
  def self.authenticate(user_name, user_password = '')
    encrypted_password = encrypt_a_password(user_password )
		find_by_name_and_encrypted_password_and_deleted(user_name, encrypted_password, false)
  end

  def valid_with_password?(check_confirm = false)
    valid?
    if check_confirm
      unless password_confirmation.nil? or password_confirmation == password
        errors.add("password", :confirmation)
      end
    end

    unless password.to_s =~ /^(?=.*\d)(?=.*[a-zA-Z])(?!.*[^\da-zA-Z]).{4,20}$/
      errors.add("password", :invalid, :default => :password_format)
    end
    errors.empty?
  end

  # override
  def before_save
    return false if monster?
    self.encrypted_password = User.encrypt_a_password(password) if password
  end

  # override
  def after_save
    # save extra attributes into redis
    e_save!

    m = "  UPDATE USER #{name}(#{id}), FIELDS: "
    fields = changed - ["updated_at", "last_activity_time"]    
    fields.each do |field|
      m += "#{field} -> #{self[field]}, "
    end
    logger.info m
  end

  # override
#  def before_create
#    self.name = self.up_name
#  end

  def after_initialize
  end

  def register(confirmed = false)
    self.active = true
    self.confirmed_email = confirmed

    self.gender = 'm' if self.gender.blank?

    self.a_level = GameProperties::USER_INITIAL_LEVEL
    self.a_money = GameProperties::USER_INITIAL_MONEY
    self.a_staff = GameProperties::USER_INITIAL_STAFF
    #    self.a_staff2 = GameProperties::USER_INITIAL_STAFF2
    self.a_power = GameProperties::USER_INITIAL_POWER
    self.a_protection = GameProperties::USER_INITIAL_PROTECTION
    self.a_dexterity = GameProperties::USER_INITIAL_DEXTERITY
    self.a_weight = GameProperties::USER_INITIAL_WEIGHT
    self.a_skill = GameProperties::USER_INITIAL_SKILL
    self.a_reputation = GameProperties::USER_INITIAL_REPUTATION
    self.a_experience = GameProperties::USER_INITIAL_EXPERIENCE
    self.a_health = GameProperties::USER_INITIAL_HEALTH

    self.chat_room = GameProperties::CHAT_PUBLIC_NAME

    self.e_fights_count = GameProperties::USER_INITIAL_FIGHTS

    # by default user has no events and messages so we mark them as read
    self.e_events_read_at = Time.now
    self.e_incoming_read_at = Time.now
    self.e_messages_read_at = Time.now

    self.attacker_message = User.t(:default_attacker_message)
    
    # we should adjust attributes first time
    adjust_attributes true, false
  end

  def remember_me!
    self.remember_token = User.encrypt_a_password("#{id}--#{Time.now.utc}")
    save_without_validation
  end

  def user_attributes(options = {})
    return @ua && @ua[options] if @ua && @ua[options]
    @ua ||= {}
    @ua[options] = UserExt::UserAttributes.new(self, options)
    @ua[options]
  end

  def reload_attributes
    @ua = nil
  end

  def self.find_md5_email(md5)
    self.find :first, :conditions => ["MD5(CONCAT('-7wiz',email)) = ?", md5]
  end

  def email_md5
    Digest::MD5.hexdigest("-7wiz#{self.email}")
  end

  def bigpoint?
    !self.bp_user_id.nil? && self.bp_user_id > 0
  end

  def hi5?
    !self.hi5_id.nil? && self.hi5_id > 0
  end

  def facebook?
    !self.fb_id.nil? && self.fb_id > 0
  end

  #
  #  # will return time in minutes
  #  def remaining_time
  #    r = 0
  #
  #    if is_working?
  #      r = work_end_time - Time.now
  #    else
  #      if in_patrol?
  #        r = patrol_end_time - Time.now
  #      end
  #    end
  #
  #    r
  #  end

#  def up_name(name = nil)
#    self.name = name if name
#    self.name = self.name.capitalize
#    self.name = self.name.gsub(/(_[a-zA-Z])/).each do |i| i.upcase end
#    self.name
#  end
  
  private

  # private class methods
  def self.encrypt_a_password(password)
    Digest::MD5.hexdigest(password)
  end
  
end

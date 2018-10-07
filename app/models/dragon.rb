class Dragon < ActiveRecord::Base

  # include base mode behaviour
  include BaseModel
  include DragonExt::Shared
  include DragonExt::Skin

  has_many :attackers, :autosave => true, :class_name => 'DragonUser'
  belongs_to :killed_by, :class_name => 'User', :foreign_key => 'killed_by_id'

  KIND_NORMAL = 1
  KIND_DOUBLE_HEALTH = 2
  KIND_DOUBLE_POWER = 3
  
  def self.current
    Dragon.find :first,
      :conditions => ['arrived_at < ? and killed is null and flew is null', Time.now]
  end

  def self.last_planned
    Dragon.find :first,
      :order => 'id desc'
  end

  def self.last_arrived
    Dragon.find :first,
      :conditions => ['killed = ? or flew = ?', true, true],
      :order => 'id desc'
  end

  def self.planned_today?
    d = last_planned
    d && d.arrived_at.today?
  end

  def last_damaged_at
    u = DragonUser.find :first,
      :select => 'updated_at',
      :conditions => ['dragon_id = ?', self.id],
      :order => 'updated_at desc',
      :limit => 1
    u ? u.updated_at : nil
  end

  def get_attacker(user)
    u = DragonUser.find_by_dragon_id_and_user_id(self.id, user.id)
    if !u
      u = DragonUser.new
      u.dragon = self
      u.user = user
      u.damage = 0
      u.received_money = 0
    end
    u
  end

  # we need fake user just for fight process
  def user(options = {})

    options = options.dup
    options[:cache] = true

    a = user_attributes options

    u = User.new
    
    u.name = Dragon.tf(Dragon, :dragon_name)
    u.a_level = a.a_level
    u.a_power = a.a_power
    u.a_protection = a.a_protection
    u.a_dexterity = a.a_dexterity
    u.a_weight = a.a_weight
    u.a_skill = a.a_skill
    u.a_health = a.a_health
    u.confirmed_email = true

    u.dragon_kind = kind
    
    u
  end

  def user_attributes(options = {})
    cache = options[:cache]
    return @da if cache && @da
    @da = DragonExt::DragonAttributes.new(self, options)
  end

  def dying?
    a_health - current_damage < GameProperties::DRAGON_MIN_HEALTH
  end

  def current_damage
    sql = <<-SQL
      select sum(damage) from dragon_users
      where dragon_id = #{self.id}
    SQL
    r = select_value sql
    r = r.to_i if r
    r || 0
  end

  def name
    user_attributes.name
  end

  def description
    l = self.a_level
    if l == 1
      description = Dragon.t(:dragon_description, :level => l)
    elsif self.kind == Dragon::KIND_DOUBLE_HEALTH
      description = Dragon.t(:double_health_dragon, :level => l)
    elsif self.kind == Dragon::KIND_DOUBLE_POWER
      description = Dragon.t(:double_power_dragon, :level => l)
    else
      description = Dragon.t(:new_dragon, :level => l)
    end
    description
  end

end

class DragonExt::DragonAttributes

  require 'yaml'

  include DragonExt::Shared
  include Helpers::TranslateHelper

  attr_accessor :arrived_at, :killed_at, :kind,
      :killed, :flew, :damage, :money, :full_health,
      :a_level, :a_health, :a_power, :a_protection, :a_dexterity, :a_weight, :a_skill

  def initialize(dragon = nil, options = {})
    if (dragon)
      @kind = dragon.kind
      @a_level = dragon.a_level

      @flew = dragon.flew
      @arrived_at = dragon.arrived_at
      @killed_at = dragon.killed_at
      @killed = dragon.killed
      @money = dragon.killed? ? dragon.money : 0
      @damage = dragon.killed? || dragon.left? ? dragon.damage : dragon.current_damage || 0
      @full_health = dragon.a_health
      
      @a_health = @damage ? [@full_health - @damage, 0].max : @full_health

      @a_power = dragon.a_power
      @a_protection = dragon.a_protection
      @a_dexterity = dragon.a_dexterity
      @a_weight = dragon.a_weight
      @a_skill = dragon.a_skill
    end
  end

  def name
    tf(Dragon, :dragon_name)
  end

  def clan_name
    nil
  end

  def dying?
    full_health - damage < GameProperties::DRAGON_MIN_HEALTH
  end

  def health_label
    "#{a_health} (#{full_health})"
  end

  def get_value(v)
    self.send(v)
  end

  def full_power
    @a_power
  end

  def full_protection
    @a_protection
  end

  def full_dexterity
    @a_dexterity
  end

  def full_weight
    @a_weight
  end

  def full_skill
    @a_skill
  end

  def full_power_label
    full_power.to_s
  end

  def full_protection_label
    full_protection.to_s
  end

  def full_dexterity_label
    full_dexterity.to_s
  end

  def full_skill_label
    full_skill.to_s
  end

  def full_weight_label
    full_weight.to_s
  end

   def md5
    h  = @a_level.to_s
    h << @a_power.to_s
    h << @a_protection.to_s
    h << @a_dexterity.to_s
    h << @a_skill.to_s
    h << @a_weight.to_s
    Digest::MD5.hexdigest(h)
  end

end

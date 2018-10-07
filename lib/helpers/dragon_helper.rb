class Helpers::DragonHelper

  class << self
    include RedisSupport
  end

  def self.create_dragon(arrived_at)
    dragon = nil

    RedisLock.lock "dragon" do
      dragon = create_next_dragon :arrived_at => arrived_at
    end
    
    dragon
  end

  def self.kill_dragon(user)
    RedisLock.lock "dragon" do
      dragon = Dragon.current
      return if !dragon || !dragon.dying?

      damage = dragon.current_damage
      last_damaged_at = dragon.last_damaged_at
      damage_price = dragon.money.to_f / damage

      dragon.transaction do
        dragon.damage = damage
        dragon.killed = true
        dragon.killed_at = last_damaged_at
        dragon.killed_by = user
        dragon.save!

        dragon.attackers.each do |a|
          u = a.user
          a.received_money = a.damage * damage_price
          u.add_money(a.received_money, "fight gragon")

          message_key = :dragon_killed
          message_params = { :level => a.dragon.a_level, :money => Message.tp(a.received_money), :damage => a.damage }

          if u == user
            if dragon.staff2 > 0
              a.received_staff2 = dragon.staff2
              u.a_staff += dragon.staff2
              
              message_key = :dragon_killed_by_you_and_bonus
              message_params[:staff2] = Message.tps(a.received_staff2)
            else
              message_key = :dragon_killed_by_you
            end
          end

          Message.create_dragon_event u, message_key, message_params

          a.save!
          u.save!
        end

        create_next_dragon :previous_dragon => dragon
      end
    end
  end

  def self.fly_away_dragon
    RedisLock.lock "dragon" do
      dragon = Dragon.current
      return if !dragon || dragon.leave_at > Time.now
      
      dragon.damage = dragon.current_damage
      dragon.flew = true
      dragon.save!

      dragon.attackers.each do |a|
        u = a.user
        Message.create_dragon_event u, :dragon_left, :damage => a.damage, :level => a.dragon.a_level
      end
    end
  end

  private

  def self.create_next_dragon(options = {})

    previous_dragon = options[:previous_dragon]
    if previous_dragon
      level = previous_dragon.a_level
      if level >= GameProperties::DRAGON_MAX_LEVEL ||
          level >= GameProperties::DRAGON_MIN_LEVEL && (rand < GameProperties::DRAGON_LAST_PROBABILITY_PERCENT.to_percent)
        return nil
      end
    end

    dragon = Dragon.new
    dragon.kind = Dragon::KIND_NORMAL
    dragon.arrived_at = options[:arrived_at] || previous_dragon.arrived_at

    dragon.a_level = previous_dragon ? previous_dragon.a_level + 1 : 1
    
    dragon.a_power = calculate_dragon_param dragon.a_level
    dragon.a_protection = calculate_dragon_param dragon.a_level
    dragon.a_dexterity = calculate_dragon_param dragon.a_level
    dragon.a_skill = calculate_dragon_param dragon.a_level
    dragon.a_weight = calculate_dragon_param dragon.a_level

    dragon.money = GameProperties::DRAGON_MONEY.call(dragon.a_level, previous_dragon ? previous_dragon.money : 0)
    dragon.a_health = GameProperties::DRAGON_HEALTH.call(dragon.a_level)

    dragon.money = randomize_param dragon.money
    dragon.a_health = randomize_param dragon.a_health

    double_health_percent, double_power_percent, full_bonus_staff2 =
      GameProperties::DRAGON_DOUBLE_HEALTH_DOUBLE_POWER_AND_BONUS.call(dragon.a_level)

    if rand < double_health_percent.to_percent
      dragon.a_health *= 2
      dragon.staff2 = full_bonus_staff2
      dragon.kind = Dragon::KIND_DOUBLE_HEALTH
    elsif rand < double_power_percent.to_percent
      dragon.a_power *= 2
      dragon.staff2 = full_bonus_staff2
      dragon.kind = Dragon::KIND_DOUBLE_POWER
    end

    dragon.save!
    
    dragon
  end

  def self.calculate_dragon_param(level)
    value = 60 + level * 40
    randomize_param value/2
  end

  def self.randomize_param(value)
    r = rand(3)
    if r == 1
      value = value.to_f * (1 + rand(3).to_percent)
    elsif r == 2
      value = value.to_f * (1 - rand(3).to_percent)
    end
    value.to_i
  end

end

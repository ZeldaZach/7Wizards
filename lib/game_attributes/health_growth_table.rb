class HealthGrowthTable < AbstractGrowthTable

  def self.get_max_health(user, pet = false, options = {})
    get_attribute_value(:max_health, user, pet, options)
  end

  def self.get_hour_regeneration(user, pet = false, options = {})
    get_attribute_value(:hour_regeneration, user, pet, options)
  end

  def self.reset
    @@values = nil
    get_values
  end

  private

  def self.get_attribute_value(name, user, pet = false, options = {})
    if user.dragon?
      level = user.a_weight
    else
      user_a = user.user_attributes
      if pet
        level = user_a.pet_weight
      else
        if options[:use_clear_attributes]
          level = user.a_weight
        else
          level = user_a.full_weight
        end
      end
    end
    values = get_values
    values = values[level]
    result = values ? values[name] : nil
    result ? result.to_i : 0
  end

  @@values = nil

  def self.get_values

    return @@values if @@values

    @@values = {}

    read_table_lines("health_growth_table") do |line|
      values = line.split
      level, max_health, hour_regeneration = values

      @@values[level.to_i] = {
        :max_health => max_health.to_i,
        :hour_regeneration => hour_regeneration.to_i
      }
    end

    @@values
  end

end

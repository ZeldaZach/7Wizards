class UserAttributesGrowthTable < AbstractGrowthTable

  def self.get_power_price(user, pet = false)
    get_price(user, :power, pet)
  end

  def self.get_protection_price(user, pet = false)
    get_price(user, :protection, pet)
  end

  def self.get_dexterity_price(user, pet = false)
    get_price(user, :dexterity, pet)
  end

  def self.get_weight_price(user, pet = false)
    get_price(user, :weight, pet)
  end

  def self.get_skill_price(user, pet = false)
    get_price(user, :skill, pet)
  end

  def self.get_price(user, attribute, pet = false)
    a = pet ? "pet_#{attribute}" : "a_#{attribute}"
    level = user[a] + 1
    get_attribute_value(attribute, level)
  end

  def self.reset
    @@values = nil
    get_values
  end

  private

  @@values = nil

  def self.get_attribute_value(name, level)
    values = get_values
    values = values[level]
    result = values ? values[name] : nil
    result || 0
  end

  def self.get_values

    return @@values if @@values

    @@values = {}

    read_table_lines("attribute_growth_table") do |line|
      values = line.split
      level, power, protection, dexterity, weight, skill = values

      @@values[level.to_i] = {
        :power => power.to_i,
        :protection => protection.to_i,
        :dexterity => dexterity.to_i,
        :weight => weight.to_i,
        :skill => skill.to_i
      }
    end

    @@values
  end

end

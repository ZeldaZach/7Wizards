class MeditationGrowthTable < AbstractGrowthTable

  def self.get_current_money(user)
    level = user.a_level
    values = get_values
    result = values[level]
    result = prev_level(values, level) if result.nil?
    result || values[1]
  end

  def self.prev_level(values, level)
    level = level - 1
    result = values[level]
    result = prev_level(values, level) if result.nil? && level > 0
    result 
  end

  def self.reset
    @@values = nil
    get_values
  end

  private

  @@values = nil

  def self.get_values

    return @@values if @@values

    @@values = {}

    read_table_lines("meditation_growth_table") do |line|
      values = line.split
      level, money = values

      @@values[level.to_i] = money.to_i
    end

    @@values
  end

end

class ExperienceGrowthTable < AbstractGrowthTable

  def self.get_next_level_experience(user)
    level = user.a_level + 1
    values = get_values
    result = values[level]
    result || 0
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

    read_table_lines("experience_growth_table") do |line|
      values = line.split
      level, experience = values

      @@values[level.to_i] = experience.to_i
    end

    @@values
  end

end

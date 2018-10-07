class AbstractGrowthTable

  def self.reset
    # should be implemented in extended classes
  end

  def self.read_table_lines(file_name, ignore_header = true)
    File.open(File.join(Rails.root, "config", "game", "tables", "#{file_name}.txt"), "r") do |f|
      line = f.gets if ignore_header
      while line = f.gets
        yield line
      end
    end
  end

end

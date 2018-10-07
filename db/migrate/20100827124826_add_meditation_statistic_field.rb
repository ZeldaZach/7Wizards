class AddMeditationStatisticField < ActiveRecord::Migration
  def self.up
    rename_column :users, :meditation_minutes_experience, :s_meditation_minutes
  end

  def self.down
    rename_column :users, :s_meditation_minutes, :meditation_minutes_experience
  end
end

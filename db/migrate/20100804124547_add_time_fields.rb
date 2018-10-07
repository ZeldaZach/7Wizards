class AddTimeFields < ActiveRecord::Migration
  def self.up
    add_column :users, :plantation_updated_at, :datetime
    add_column :users, :daily_bonus_updated_at, :datetime
    add_column :users, :meditation_started_at, :datetime
    add_column :users, :meditation_finished_at, :datetime
    add_column :users, :meditation_experience, :integer
    add_column :users, :meditation_money, :integer
    add_column :users, :meditation_minutes_experience, :integer, :default => 0
  end

  def self.down
    remove_column :users, :plantation_updated_at
    remove_column :users, :daily_bonus_updated_at
    remove_column :users, :meditation_started_at
    remove_column :users, :meditation_finished_at
    remove_column :users, :meditation_experience
    remove_column :users, :meditation_money
    remove_column :users, :meditation_minutes_experience
  end
end

class AddTwoStatFields < ActiveRecord::Migration
  def self.up
    add_column :users, :s_lost_protection, :integer, :default => 0, :null => false
  end

  def self.down
    remove_column :users, :s_lost_protection
  end
end

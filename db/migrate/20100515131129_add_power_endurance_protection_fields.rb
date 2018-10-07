class AddPowerEnduranceProtectionFields < ActiveRecord::Migration
  def self.up
    add_column :users, :g_power, :integer, :default => 0, :null => false
    add_column :users, :g_protection, :integer, :default => 0, :null => false
    add_column :users, :g_endudance, :integer, :default => 0, :null => false
  end

  def self.down
    remove_column :users, :g_power
    remove_column :users, :g_protection
    remove_column :users, :g_endudance
  end
end

class AddAdditionalItemsFields < ActiveRecord::Migration
  def self.up
    add_column :users, :g_power_expired_at, :datetime
    add_column :users, :g_protection_expired_at, :datetime
    add_column :users, :g_endurance_expired_at, :datetime
  end

  def self.down
    remove_column :users, :g_power_expired_at
    remove_column :users, :g_protection_expired_at
    remove_column :users, :g_endurance_expired_at
  end
end

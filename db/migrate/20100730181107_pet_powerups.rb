class PetPowerups < ActiveRecord::Migration
  def self.up
    add_column :users, :g_antipet_expired_at, :datetime
    add_column :users, :g_pet_power_expired_at, :datetime
    add_column :users, :g_pet_antikiller_expired_at, :datetime
  end

  def self.down
    remove_column :users, :g_antipet_expired_at
    remove_column :users, :g_pet_power_expired_at
    remove_column :users, :g_pet_antikiller_expired_at
  end
end

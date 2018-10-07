class AddTotalDamage < ActiveRecord::Migration
  def self.up
    add_column :users, :s_total_damage, :integer, :default => 0, :null => false
    change_column :users, :s_referral_bonus_count, :integer, :default => 0, :null => false
  end

  def self.down
    remove_column :users, :s_total_damage
  end
end

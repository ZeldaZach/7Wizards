class AddClanImprovementsFields < ActiveRecord::Migration
  def self.up
    add_column :clans, :g_clan_places, :integer, :default => 0, :null => false
    add_column :clans, :g_clan_power, :integer, :default => 0, :null => false
    add_column :clans, :g_clan_protection, :integer, :default => 0, :null => false
  end

  def self.down
    remove_column :clans, :g_clan_places
    remove_column :clans, :g_clan_power
    remove_column :clans, :g_clan_protection
  end
end

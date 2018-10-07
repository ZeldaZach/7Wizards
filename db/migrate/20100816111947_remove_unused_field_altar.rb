class RemoveUnusedFieldAltar < ActiveRecord::Migration
  def self.up

    remove_column :clans, :g_power
    remove_column :clans, :g_protection
    remove_column :clans, :g_places
    remove_column :clans, :g_academy
    remove_column :clans, :g_altar

  end

  def self.down
    #unused
    add_column :clans, :g_power, :integer
    add_column :clans, :g_protection, :integer
    add_column :clans, :g_places, :integer
    add_column :clans, :g_academy, :integer
    add_column :clans, :g_altar, :integer

  end
end

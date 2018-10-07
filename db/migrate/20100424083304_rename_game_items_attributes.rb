class RenameGameItemsAttributes < ActiveRecord::Migration
  def self.up
    remove_column :users, :a_plantation
    remove_column :users, :a_places
    remove_column :users, :a_fence
    remove_column :users, :a_clairvoyance
    remove_column :users, :a_mind

    add_column :users, :g_plantation, :integer, :null => false, :default => 0
    add_column :users, :g_places, :integer, :null => false, :default => 0
    add_column :users, :g_fence, :integer, :null => false, :default => 0
    add_column :users, :g_clairvoyance, :integer, :null => false, :default => 0
    add_column :users, :g_mind, :integer, :null => false, :default => 0
    add_column :users, :g_safe_end, :datetime
  end

  def self.down
    add_column :users, :a_plantation, :integer, :null => false, :default => 0
    add_column :users, :a_places, :integer, :null => false, :default => 0
    add_column :users, :a_fence, :integer, :null => false, :default => 0
    add_column :users, :a_clairvoyance, :integer, :null => false, :default => 0
    add_column :users, :a_mind, :integer, :null => false, :default => 0

    remove_column :users, :g_plantation
    remove_column :users, :g_places
    remove_column :users, :g_fence
    remove_column :users, :g_clairvoyance
    remove_column :users, :g_mind
    remove_column :users, :g_safe_end
  end
end

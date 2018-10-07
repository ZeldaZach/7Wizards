class AddPlantationFencePlacesFields < ActiveRecord::Migration
  def self.up
    add_column :users, :a_plantation, :integer, :null => false, :default => 0
    add_column :users, :a_places, :integer, :null => false, :default => 0
    add_column :users, :a_fence, :integer, :null => false, :default => 0
    add_column :users, :a_clairvoyance, :integer, :null => false, :default => 0
    add_column :users, :a_mind, :integer, :null => false, :default => 0
  end

  def self.down
    remove_column :users, :a_plantation
    remove_column :users, :a_places
    remove_column :users, :a_fence
    remove_column :users, :a_clairvoyance
    remove_column :users, :a_mind
  end
end

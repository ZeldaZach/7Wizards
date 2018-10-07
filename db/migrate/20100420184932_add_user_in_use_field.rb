class AddUserInUseField < ActiveRecord::Migration
  def self.up
    add_column :user_items, :in_use, :boolean, :default => false, :null => false
    change_column :user_items, :active, :boolean, :default => true, :null => false
  end

  def self.down
    remove_column :user_items, :in_use
    change_column :user_items, :active, :boolean, :default => true, :null => true
  end
end

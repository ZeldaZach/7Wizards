class AddUserItemType < ActiveRecord::Migration
  def self.up
    add_column :user_items, :type, :string
  end

  def self.down
    remove_column :user_items, :type
  end
end

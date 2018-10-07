class AddNewUserItemsFields < ActiveRecord::Migration
  def self.up
    add_column :user_items, :bought_by_id, :integer, :null => false
    add_column :user_items, :reasigned_at, :datetime
    add_column :user_items, :active_till, :datetime
  end

  def self.down
    remove_column :user_items, :bought_by_id
    remove_column :user_items, :reasigned_at
    remove_column :user_items, :active_till
  end
end

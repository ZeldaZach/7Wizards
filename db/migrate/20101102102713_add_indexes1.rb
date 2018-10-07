class AddIndexes1 < ActiveRecord::Migration
  def self.up
    change_column :user_tasks, :user_id, :integer, :null => false, :default => 0
    add_index :user_tasks, [:user_id, :name]
    add_index :user_avatars, :user_id
  end

  def self.down
    remove_index :user_tasks, [:user_id, :name]
    remove_index :user_avatars, :user_id
  end
end

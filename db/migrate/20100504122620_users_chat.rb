class UsersChat < ActiveRecord::Migration
  def self.up
    add_column :users, :chat_room, :string, :limit => 30
    add_column :users, :chat_activity_time, :datetime
  end

  def self.down
    remove_column :users, :chat_room
    remove_column :users, :chat_activity_time
  end
end

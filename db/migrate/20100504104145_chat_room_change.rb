class ChatRoomChange < ActiveRecord::Migration
  def self.up
    change_column :chat, :room, :string, :limit => 30, :null => false
  end

  def self.down
    change_column :chat, :room, :string, :limit => 2
  end
end

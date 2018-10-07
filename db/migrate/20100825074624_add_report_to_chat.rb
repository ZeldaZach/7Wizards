class AddReportToChat < ActiveRecord::Migration
  def self.up
    rename_table :chat, :chats
    add_column :chats, :report,    :integer,  :default => 0
    add_column :chats, :last_reporter_id,  :integer
  end

  def self.down
    remove_column :chats, :last_reporter_id
    remove_column :chats, :report
    rename_table :chats, :chat
  end
end

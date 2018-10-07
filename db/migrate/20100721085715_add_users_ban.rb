class AddUsersBan < ActiveRecord::Migration
  def self.up
    create_table "ban_histories", :force => true,  :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.integer  "user_id"
      t.boolean  "ban"
      t.string   "public_reason"
      t.string   "private_reason"
      t.datetime "ban_end_date"
      t.integer  "banned_by_id"
      t.boolean  "only_messages",  :default => false, :null => false
      t.datetime "created_at"
      t.datetime "updated_at"
    end
    add_column :users, :active_messaging, :boolean, :default => true, :null => false 
  end

  def self.down
    remove_column :users, :active_messaging
    drop_table :ban_histories
  end
end

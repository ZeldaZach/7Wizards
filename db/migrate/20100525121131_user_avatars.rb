class UserAvatars < ActiveRecord::Migration
  def self.up
    create_table "user_avatars" do |t|
      t.integer  :user_id,   :null => false
      t.string   :key,       :null => false
      t.boolean  :active,    :null => false, :default => false
      t.datetime :created_at
      t.datetime :updated_at
    end
  end

  def self.down
    drop_table :user_avatars
  end
end

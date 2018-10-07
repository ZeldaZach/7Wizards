class FacebookUser < ActiveRecord::Migration
  def self.up
    add_column :users , :fb_id, :bigint, :null => false, :default => 0
    add_column :users,  :fb_email, :string, :null => true
    add_column :users,  :fb_name,  :string, :null => true
    add_column :users,  :hi5_name, :string, :null => true
  end

  def self.down
    remove_column :users,  :fb_id
    remove_column :users,  :fb_email
    remove_column :users,  :fb_name
    remove_column :users,  :hi5_name
  end
end

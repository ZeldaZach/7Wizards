class BigPointFields < ActiveRecord::Migration
  def self.up
    add_column :users, :bp_user_id, :integer, :null => true
    add_column :users, :bp_affiliate_id, :integer, :null => true
    add_column :users, :bp_name, :string
    add_column :users, :bp_user_country, :string
  end

  def self.down
    remove_column :users, :bp_user_id
    remove_column :users, :bp_affiliate_id
    remove_column :users, :bp_name
    remove_column :users, :bp_user_country
  end
end

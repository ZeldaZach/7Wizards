class Hi5Migration < ActiveRecord::Migration
  def self.up
    add_column :users, :hi5_id, :integer, :null => true
  end

  def self.down
    remove_column :users, :hi5_id
  end
end

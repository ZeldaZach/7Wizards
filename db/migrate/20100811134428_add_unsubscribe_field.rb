class AddUnsubscribeField < ActiveRecord::Migration
  def self.up
    add_column :users, :unsubscribe, :boolean, :default => false
  end

  def self.down
    remove_column :users, :unsubscribe
  end
end

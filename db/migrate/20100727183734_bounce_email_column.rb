class BounceEmailColumn < ActiveRecord::Migration
  def self.up
    add_column :users, :bounced_email, :boolean, :default => false
  end

  def self.down
    remove_column :users, :bounced_email
  end
end

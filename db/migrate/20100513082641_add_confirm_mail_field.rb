class AddConfirmMailField < ActiveRecord::Migration
  def self.up
    add_column :users, :confirmed_email, :boolean, :default => false, :null => false
  end

  def self.down
    remove_column :users, :confirmed_email, :boolean
  end
end

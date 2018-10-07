class AddStaffToAdyen < ActiveRecord::Migration
  def self.up
    add_column :adyen_notifications, :staff, :integer, :default => 0
  end

  def self.down
    remove_column :adyen_notifications, :staff
  end
end

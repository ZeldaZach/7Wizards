class AddSafe2GameField < ActiveRecord::Migration
  def self.up
    remove_column :users, :g_safe_end
    add_column :users, :g_safe_expired_at, :datetime
    add_column :users, :g_safe2_expired_at, :datetime
  end

  def self.down
  end
end

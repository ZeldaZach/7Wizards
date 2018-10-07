class FixUserField < ActiveRecord::Migration
  def self.up
    rename_column(:users, :g_mind, :g_cloaking)
  end

  def self.down
  end
end

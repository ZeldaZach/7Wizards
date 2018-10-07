class AddActiveColumnRelation < ActiveRecord::Migration
  def self.up
    add_column :relations, :active, :boolean
    add_column :relations, :request_message, :text
    remove_index :relations, [:relative_id, :user_id]
    add_index :relations, [:active, :relative_id, :user_id]
  end

  def self.down
    remove_column :relations, :active
    remove_column :relations, :request_message, :text
    add_index :relations, [:relative_id, :user_id]
    remove_index :relations, [:active, :relative_id, :user_id]
  end
end

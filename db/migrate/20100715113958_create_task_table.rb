class CreateTaskTable < ActiveRecord::Migration
  def self.up
    create_table "user_tasks", :force => true do |t|
      t.string   "user_id",    :null => false
      t.string   "name",       :null => false
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end

  def self.down
    drop_table :user_tasks
  end
end

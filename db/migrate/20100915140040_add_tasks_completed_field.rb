class AddTasksCompletedField < ActiveRecord::Migration
  def self.up
    add_column :users, :tutorial_done, :boolean, :defalult => false
  end

  def self.down
    remove_column :users, :tutorial_done
  end
end

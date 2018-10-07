class AddAvatarsType < ActiveRecord::Migration
  def self.up
    remove_column :user_avatars, :active
    
    add_column :user_avatars, :type, :text
    add_column :user_avatars, :body_color, :string, :size => 11
  end

  def self.down
    remove_column :user_avatars, :type
    remove_column :user_avatars, :body_color

    add_column :user_avatars, :active, :boolean
  end
end

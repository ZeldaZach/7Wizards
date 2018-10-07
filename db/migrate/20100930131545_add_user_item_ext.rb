class AddUserItemExt < ActiveRecord::Migration
  def self.up
    add_column :user_items, :ext, :integer, :default => 0, :null => false
    User.all.each do |u|
      UserItems::AchivementElders.extend(u, 1)
    end

    #AVATAR REFACTORING
    UserAvatar.update_all("type = 'UserAvatars::Female1'", "user_avatars.key = 'female1'")
    UserAvatar.update_all("type = 'UserAvatars::Female2'", "user_avatars.key = 'female2'")
    UserAvatar.update_all("type = 'UserAvatars::Female3'", "user_avatars.key = 'female3'")

    UserAvatar.update_all("type = 'UserAvatars::Male1'", "user_avatars.key = 'male1'")
    UserAvatar.update_all("type = 'UserAvatars::Male2'", "user_avatars.key = 'male2'")
    UserAvatar.update_all("type = 'UserAvatars::Male3'", "user_avatars.key = 'male3'")  
  end

  def self.down
    remove_column :user_items, :ext
  end
end

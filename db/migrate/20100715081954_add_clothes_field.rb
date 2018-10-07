class AddClothesField < ActiveRecord::Migration
  def self.up
    add_column :user_avatars, :clothes, :text
#    all = UserAvatar.find :all
#    all.each do |ava|
#      ava.clothes = AvatarClothes.get_default_clothes
#      ava.save!
#    end
  end

  def self.down
    remove_column :user_avatars, :clothes
  end
end

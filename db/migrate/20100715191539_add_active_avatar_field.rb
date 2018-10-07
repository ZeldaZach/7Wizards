class AddActiveAvatarField < ActiveRecord::Migration
  def self.up
    add_column :users, :active_avatar_id, :integer, :null => false
    change_column :user_avatars, :user_id, :integer, :null => true
#    remove_column :user_avatars, :active
#    all = User.find :all
#    all.each do |u|
#      if u.active_avatar_id == 0
#        ava = UserAvatar.find_by_user_id_and_active(u.id, 1)
#        if ava.nil?
#          ava = u.register_davatar
#          if u.save
#            ava.user = u
#            ava.save
#          end
#        else
#          u.active_avatar_id = ava.id
#          u.save
#        end
#      end
#    end
  end

  def self.down
    add_column :user_avatars, :active, :boolean
    remove_column :users, :active_avatar_id
  end
end

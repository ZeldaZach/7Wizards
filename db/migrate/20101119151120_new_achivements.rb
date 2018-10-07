class NewAchivements < ActiveRecord::Migration
  def self.up
    add_column :users, :g_achivement_champion, :integer, :default => 0
    add_column :users, :g_achivement_damage, :integer, :default => 0
    add_column :users, :g_achivement_elders, :integer, :default => 0
    add_column :users, :g_achivement_hero, :integer, :default => 0
    add_column :users, :g_achivement_meditation, :integer, :default => 0
    add_column :users, :g_achivement_stealer, :integer, :default => 0
    add_column :users, :g_achivement_pet_kills, :integer, :default => 0
    add_column :users, :g_achivement_won_wars, :integer, :default => 0
    add_column :users, :g_achivement_dragons, :integer, :default => 0
    add_column :users, :g_achivement_gifts, :integer, :default => 0

    sql = "SELECT user_items.user_id, user_items.key, user_items.ext FROM user_items where user_items.type like 'UserItems::Achivement%'"

    achivements = UserItem.find_by_sql sql
    achivements.each do |a|
      if a.key == 'ach01'
        a.user.g_achivement_elders = a.ext
      elsif a.key == 'ach02'
        a.user.g_achivement_meditation = a.ext
      elsif a.key == 'ach03'
        a.user.g_achivement_stealer = a.ext
      elsif a.key == 'ach04'
        a.user.g_achivement_champion = a.ext
      elsif a.key == 'ach05'
        a.user.g_achivement_damage = a.ext
      elsif a.key == 'ach06'
        a.user.g_achivement_hero = a.ext
      end
      a.user.save
#      a.destroy
    end
#    remove_column :user_items, :ext
  end

  def self.down
    remove_column :users, :g_achivement_champoin
    remove_column :users, :g_achivement_damage
    remove_column :users, :g_achivement_elders
    remove_column :users, :g_achivement_hero
    remove_column :users, :g_achivement_meditation
    remove_column :users, :g_achivement_stealer
    remove_column :users, :g_achivement_pet_kills
    remove_column :users, :g_achivement_won_wars
    remove_column :users, :g_achivement_dragons
    remove_column :users, :g_achivement_gifts
  end
end

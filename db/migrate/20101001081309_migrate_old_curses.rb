class MigrateOldCurses < ActiveRecord::Migration
  def self.up
    UserItem.update_all "type = 'UserItems::ShopCurseCurseC01'", "type = 'UserItems::ShopCursesCursesC01'"
    UserItem.update_all "type = 'UserItems::ShopCurseCurseC02'", "type = 'UserItems::ShopCursesCursesC02'"
    UserItem.update_all "type = 'UserItems::ShopCurseCurseC03'", "type = 'UserItems::ShopCursesCursesC03'"
    UserItem.update_all "type = 'UserItems::ShopCurseCurseC04'", "type = 'UserItems::ShopCursesCursesC04'"

    add_column :user_items, :category, :string

    AllUserItems.categories.each do |cat|
      keys = AllUserItems.get_category_keys cat
      UserItem.update_all ['category = ?', cat.to_s], ['`key` in (?)', keys]
    end

    change_column :user_items, :category, :string, :null => false

    add_column :users, :s_sent_curses, :integer, :default => 0
    add_column :users, :s_received_curses, :integer, :default => 0
    add_column :users, :s_sent_gifts, :integer, :default => 0
    add_column :users, :s_received_gifts, :integer, :default => 0

    add_index :user_items, [:bought_by_id, :reasigned_at], :name => "by_buyer"
  end

  def self.down
    remove_column :users, :s_sent_curses
    remove_column :users, :s_received_curses
    remove_column :users, :s_sent_gifts
    remove_column :users, :s_received_gifts

    remove_column :user_items, :category
    remove_index :user_items, :name => "by_buyer"
  end
  
end

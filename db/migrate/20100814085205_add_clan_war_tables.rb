class AddClanWarTables < ActiveRecord::Migration
  def self.up
    create_table "clan_war_users", :force => true do |t|
      t.integer  "war_id",                                      :null => false
      t.integer  "user_id"
      t.integer  "clan_id",                                     :null => false
      t.integer  "protection",                                  :null => false
      t.integer  "damage",                                      :null => false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "lost_protection",                             :null => false
      t.integer  "fights",                       :default => 0, :null => false
      t.integer  "attacks",                      :default => 0, :null => false
      t.integer  "wins",                         :default => 0, :null => false
      t.integer  "union_fights",                 :default => 0, :null => false
      t.integer  "union_wins",                   :default => 0, :null => false
      t.string   "formation",       :limit => 1
      t.string   "kind"
      t.integer  "level"
      t.binary   "extra_bin"
    end

    add_index "clan_war_users", ["clan_id", "war_id"]

    create_table "clan_wars", :force => true do |t|
      t.integer  "clan_id",                               :null => false
      t.integer  "clan_owner_id",                         :null => false
      t.integer  "opponent_clan_id",                      :null => false
      t.integer  "opponent_clan_owner_id",                :null => false
      t.boolean  "clan_won"
      t.integer  "winner_money"
      t.datetime "started_at",                            :null => false
      t.datetime "finished_at"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "finish_reason"
      t.integer  "winner_staff2",          :default => 0, :null => false
    end

    add_index "clan_wars", ["clan_id"]
    add_index "clan_wars", ["opponent_clan_id"]

    add_column :clans, :g_clan_altar, :integer, :default => 0, :null => false
    add_column :users, :current_clan_war_user_id, :integer

    add_column :clans, :s_loses_count, :integer, :default => 0, :null => false
    add_column :clans, :s_wins_count, :integer, :default => 0, :null => false
    add_column :clans, :s_lost_money, :integer, :default => 0, :null => false
    add_column :clans, :s_loot_money, :integer, :default => 0, :null => false
    add_column :clans, :s_lost_staff2, :integer, :default => 0, :null => false
    add_column :clans, :s_loot_staff2, :integer, :default => 0, :null => false
  end

  def self.down
    remove_column :clans, :g_clan_altar
    remove_column :users, :current_clan_war_user_id

    remove_column :clans, :s_loses_count
    remove_column :clans, :s_wins_count
    remove_column :clans, :s_lost_money
    remove_column :clans, :s_loot_money
    remove_column :clans, :s_lost_staff2
    remove_column :clans, :s_loot_staff2
  end
end

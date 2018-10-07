class AddFightLogsTable < ActiveRecord::Migration
  def self.up
    create_table "fight_logs", :force => true do |t|
      t.integer  "user_id",                                    :null => false
      t.integer  "opponent_id"
      t.boolean  "user_won",                                   :null => false
      t.integer  "won_reason",              :default => 0,     :null => false
      t.integer  "winner_money_diff",                          :null => false
      t.integer  "winner_staff2_diff",      :default => 0,     :null => false
      t.integer  "winner_health_diff",                         :null => false
      t.integer  "winner_reputation",       :default => 0,     :null => false
      t.integer  "winner_experience",       :default => 0,     :null => false
      t.integer  "winner_pet_health_diff",  :default => 0,     :null => false
      t.boolean  "winner_pet_killed",       :default => false, :null => false
      t.integer  "loser_money_diff",                           :null => false
      t.integer  "loser_health_diff",                          :null => false
      t.integer  "loser_pet_health_diff",   :default => 0,     :null => false
      t.boolean  "loser_pet_killed",        :default => false, :null => false
      t.boolean  "pet_fight",               :default => false
      t.integer  "user_pet_reanimate"
      t.integer  "opponent_pet_reanimate"
      t.boolean  "clan_war",                :default => false, :null => false
      t.boolean  "user_union_fight"
      t.boolean  "opponent_union_fight"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.boolean  "amulet_antimag_user",     :default => false, :null => false
      t.boolean  "amulet_antimag_opponent", :default => false, :null => false
      t.boolean  "amulet_diablo_user",      :default => false, :null => false
      t.boolean  "amulet_diablo_opponent",  :default => false, :null => false
    end

    add_index "fight_logs", ["opponent_id", "created_at"], :name => "index_fight_logs_on_opponent_id_and_created_at"
    add_index "fight_logs", ["user_id", "opponent_id", "created_at"], :name => "index_fight_logs_on_user_id_and_opponent_id_and_created_at"
  end

  def self.down
    drop_table :fight_logs
  end
end

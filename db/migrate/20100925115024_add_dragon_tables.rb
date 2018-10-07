class AddDragonTables < ActiveRecord::Migration
  def self.up
    create_table "dragon_users", :force => true do |t|
      t.integer  "dragon_id",                      :null => false
      t.integer  "user_id",                        :null => false
      t.integer  "damage",                         :null => false
      t.integer  "received_money",                 :null => false
      t.integer  "received_staff2", :default => 0
      t.integer  "attacks_count",   :default => 0
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "dragon_users", ["dragon_id", "user_id"], :name => "index_dragon_users_on_dragon_id_and_user_id"
    add_index "dragon_users", ["dragon_id"], :name => "index_dragon_users_on_dragon_id"
    add_index "dragon_users", ["user_id"], :name => "index_dragon_users_on_user_id"

    create_table "dragons", :force => true do |t|
      t.datetime "arrived_at",                  :null => false
      t.integer  "kind",                        :null => false
      t.boolean  "killed"
      t.boolean  "flew"
      t.datetime "killed_at"
      t.integer  "damage"
      t.integer  "money"
      t.integer  "staff2",       :default => 0
      t.integer  "a_level",                     :null => false
      t.integer  "a_health",                    :null => false
      t.integer  "a_power",                     :null => false
      t.integer  "a_protection",                :null => false
      t.integer  "a_dexterity",                 :null => false
      t.integer  "a_weight",                    :null => false
      t.integer  "a_skill",                     :null => false
      t.integer  "killed_by_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "dragons", ["arrived_at", "killed", "flew"], :name => "index_dragons_on_arrived_at_and_killed_and_flew"
    add_index "dragons", ["arrived_at"], :name => "index_dragons_on_arrived_at"

    add_column :fight_logs, :dragon_id, :integer
  end

  def self.down
    remove_column :fight_logs, :dragon_id, :integer
  end
end

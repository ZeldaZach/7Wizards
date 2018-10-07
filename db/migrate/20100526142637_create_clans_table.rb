class CreateClansTable < ActiveRecord::Migration
  def self.up
    create_table "clans", :force => true do |t|
      t.string   "name",                               :null => false
      t.string   "description"
      t.integer  "owner_id",                           :null => false
      t.integer  "creator_id",                         :null => false
      t.string   "avatar"
      t.boolean  "active",           :default => true, :null => false
      t.text     "stats"
      t.integer  "a_money",          :default => 0,    :null => false
      t.integer  "a_staff2",         :default => 0,    :null => false
      t.integer  "g_power",          :default => 0,    :null => false
      t.integer  "g_protection",     :default => 0,    :null => false
      t.integer  "g_places",         :default => 0,    :null => false
      t.integer  "g_academy",        :default => 0,    :null => false
      t.integer  "g_altar",          :default => 0,    :null => false
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end

  def self.down
  end
end

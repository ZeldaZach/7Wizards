# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20101123151231) do

  create_table "adyen_notifications", :force => true do |t|
    t.boolean  "live",                                                             :default => false, :null => false
    t.string   "event_code",                                                                          :null => false
    t.string   "psp_reference",                                                                       :null => false
    t.string   "original_reference"
    t.string   "merchant_reference",                                                                  :null => false
    t.string   "merchant_account_code",                                                               :null => false
    t.datetime "event_date",                                                                          :null => false
    t.boolean  "success",                                                          :default => false, :null => false
    t.string   "payment_method"
    t.string   "operations"
    t.text     "reason"
    t.string   "currency",              :limit => 3,                                                  :null => false
    t.decimal  "value",                              :precision => 9, :scale => 2
    t.boolean  "processed",                                                        :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "compleated",                                                       :default => false
    t.integer  "user_id"
    t.integer  "staff",                                                            :default => 0
  end

  add_index "adyen_notifications", ["psp_reference", "event_code", "success"], :name => "adyen_notification_uniqueness", :unique => true

  create_table "app_properties", :force => true do |t|
    t.string   "name",       :null => false
    t.string   "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "avatar_votings", :force => true do |t|
    t.integer  "user_id",        :null => false
    t.integer  "user_avatar_id", :null => false
    t.integer  "voter_id",       :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ban_histories", :force => true do |t|
    t.integer  "user_id"
    t.boolean  "ban"
    t.string   "public_reason"
    t.string   "private_reason"
    t.datetime "ban_end_date"
    t.integer  "banned_by_id"
    t.boolean  "only_messages",  :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "bigpoint_payments", :force => true do |t|
    t.string   "payment_type",              :default => "", :null => false
    t.integer  "amount",                                    :null => false
    t.string   "unique_id",                 :default => "", :null => false
    t.string   "account_type",              :default => "", :null => false
    t.string   "user_amount_currency"
    t.integer  "user_revenue"
    t.string   "user_revenue_currency"
    t.string   "message"
    t.integer  "transaction_id"
    t.integer  "internal_info"
    t.string   "geo_country"
    t.integer  "account_id"
    t.integer  "subscription_id"
    t.integer  "subscription_date_expires"
    t.integer  "subscription_interval"
    t.integer  "timestamp"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id",                                   :null => false
  end

  create_table "chats", :force => true do |t|
    t.integer  "user_id",                                       :null => false
    t.integer  "clan_id"
    t.text     "message"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "quest_id"
    t.string   "room",             :limit => 30,                :null => false
    t.integer  "report",                         :default => 0
    t.integer  "last_reporter_id"
  end

  add_index "chats", ["clan_id"], :name => "index_chat_on_clan_id"
  add_index "chats", ["quest_id"], :name => "index_chat_on_quest_id"
  add_index "chats", ["room"], :name => "index_chat_on_room"

  create_table "clan_messages", :force => true do |t|
    t.integer  "clan_id",                   :null => false
    t.integer  "author_id"
    t.string   "title",                     :null => false
    t.text     "message"
    t.text     "extra"
    t.integer  "kind",       :default => 0, :null => false
    t.integer  "detail"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "clan_messages", ["clan_id", "kind"], :name => "index_clan_messages_on_clan_id_and_kind"

  create_table "clan_unions", :force => true do |t|
    t.integer  "clan1_id"
    t.integer  "clan2_id"
    t.boolean  "active"
    t.boolean  "killed"
    t.datetime "accepted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "clan_unions", ["clan1_id", "clan2_id"], :name => "index_clan_unions_on_clan1_id_and_clan2_id"

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

  add_index "clan_war_users", ["clan_id", "war_id"], :name => "index_clan_war_users_on_clan_id_and_war_id"

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

  add_index "clan_wars", ["clan_id"], :name => "index_clan_wars_on_clan_id"
  add_index "clan_wars", ["opponent_clan_id"], :name => "index_clan_wars_on_opponent_clan_id"

  create_table "clans", :force => true do |t|
    t.string   "name",                                :null => false
    t.string   "description"
    t.integer  "owner_id",                            :null => false
    t.integer  "creator_id",                          :null => false
    t.string   "avatar"
    t.boolean  "active",            :default => true, :null => false
    t.text     "stats"
    t.integer  "a_money",           :default => 0,    :null => false
    t.integer  "a_staff2",          :default => 0,    :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "g_clan_places",     :default => 0,    :null => false
    t.integer  "g_clan_power",      :default => 0,    :null => false
    t.integer  "g_clan_protection", :default => 0,    :null => false
    t.integer  "g_clan_altar",      :default => 0,    :null => false
    t.integer  "s_loses_count",     :default => 0,    :null => false
    t.integer  "s_wins_count",      :default => 0,    :null => false
    t.integer  "s_lost_money",      :default => 0,    :null => false
    t.integer  "s_loot_money",      :default => 0,    :null => false
    t.integer  "s_lost_staff2",     :default => 0,    :null => false
    t.integer  "s_loot_staff2",     :default => 0,    :null => false
  end

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

  create_table "event_history", :force => true do |t|
    t.string   "name",        :null => false
    t.text     "description", :null => false
    t.text     "parts",       :null => false
    t.datetime "started_at",  :null => false
    t.datetime "finished_at", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "event_history", ["started_at", "finished_at"], :name => "index_event_history_on_started_at_and_finished_at"

  create_table "event_items", :force => true do |t|
    t.integer  "event_id",   :null => false
    t.string   "key",        :null => false
    t.text     "config",     :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "events", :force => true do |t|
    t.string   "name",                           :null => false
    t.text     "description",                    :null => false
    t.boolean  "active",      :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

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
    t.integer  "dragon_id"
  end

  add_index "fight_logs", ["opponent_id", "created_at"], :name => "index_fight_logs_on_opponent_id_and_created_at"
  add_index "fight_logs", ["user_id", "opponent_id", "created_at"], :name => "index_fight_logs_on_user_id_and_opponent_id_and_created_at"

  create_table "messages", :force => true do |t|
    t.integer  "user_id",                   :null => false
    t.string   "title",                     :null => false
    t.text     "message"
    t.text     "extra"
    t.integer  "kind",       :default => 0, :null => false
    t.integer  "detail"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "messages", ["kind"], :name => "index_messages_on_kind"
  add_index "messages", ["user_id", "kind", "created_at"], :name => "index_messages_on_user_id_and_kind"

  create_table "news_messages", :force => true do |t|
    t.integer  "position"
    t.string   "title"
    t.text     "body"
    t.boolean  "published"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "news_messages", ["position", "updated_at"], :name => "index_news_messages_on_position_and_updated_at"

  create_table "partners", :force => true do |t|
    t.string   "name",       :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "host_url"
    t.string   "frame_url"
  end

  create_table "payment_logs", :force => true do |t|
    t.integer  "user_id",                                   :null => false
    t.integer  "kind",                                      :null => false
    t.string   "reason",                                    :null => false
    t.integer  "amount",                                    :null => false
    t.string   "description",                               :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "price",       :precision => 9, :scale => 2
  end

  create_table "payments", :force => true do |t|
    t.integer  "user_id",      :null => false
    t.integer  "kind",         :null => false
    t.string   "reason",       :null => false
    t.integer  "amount_staff", :null => false
    t.string   "result"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "payments", ["kind", "created_at"], :name => "index_m_gates_histories_on_kind_and_created_at"
  add_index "payments", ["user_id", "kind"], :name => "index_m_gates_histories_on_user_id_and_kind"

  create_table "quest_user_fights", :force => true do |t|
    t.integer  "quest_user_id", :null => false
    t.integer  "fight_log_id",  :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "quest_users", :force => true do |t|
    t.integer  "quest_id",                     :null => false
    t.integer  "user_id",                      :null => false
    t.integer  "user_earned",   :default => 0, :null => false
    t.integer  "user_received", :default => 0, :null => false
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "quest_users", ["user_id", "active"], :name => "index_quest_users_on_user_id_and_active"
  add_index "quest_users", ["user_id"], :name => "index_quest_users_on_user_id"

  create_table "quests", :force => true do |t|
    t.integer  "owner_id",                  :null => false
    t.string   "name",        :limit => 15, :null => false
    t.string   "status",      :limit => 2,  :null => false
    t.string   "kind",        :limit => 2,  :null => false
    t.datetime "started_at"
    t.datetime "arrived_at"
    t.datetime "finished_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description"
  end

  add_index "quests", ["status"], :name => "index_quests_on_status"

  create_table "relations", :force => true do |t|
    t.integer  "user_id",                      :null => false
    t.integer  "relative_id",                  :null => false
    t.string   "message"
    t.string   "kind",            :limit => 1, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "active"
    t.text     "request_message"
  end

  add_index "relations", ["active", "relative_id", "user_id"], :name => "index_relations_on_active_and_relative_id_and_user_id"

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "user_avatars", :force => true do |t|
    t.integer  "user_id"
    t.string   "key",        :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "clothes"
    t.text     "type"
    t.string   "body_color"
  end

  add_index "user_avatars", ["user_id"], :name => "index_user_avatars_on_user_id"

  create_table "user_items", :force => true do |t|
    t.integer  "user_id",                         :null => false
    t.string   "key",                             :null => false
    t.integer  "level",        :default => 0,     :null => false
    t.boolean  "active",       :default => true,  :null => false
    t.datetime "expired_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type"
    t.boolean  "in_use",       :default => false, :null => false
    t.integer  "bought_by_id",                    :null => false
    t.datetime "reasigned_at"
    t.datetime "active_till"
    t.integer  "ext",          :default => 0,     :null => false
    t.string   "category",                        :null => false
  end

  add_index "user_items", ["bought_by_id", "reasigned_at"], :name => "by_buyer"
  add_index "user_items", ["user_id", "active"], :name => "index_user_items_on_user_id_and_active"

  create_table "user_marketing_infos", :force => true do |t|
    t.integer  "user_id"
    t.integer  "partner_id"
    t.string   "source"
    t.string   "campaign_id"
    t.string   "keywords"
    t.string   "referrer"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_tasks", :force => true do |t|
    t.integer  "user_id",    :default => 0, :null => false
    t.string   "name",                      :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_tasks", ["user_id", "name"], :name => "index_user_tasks_on_user_id_and_name"

  create_table "users", :force => true do |t|
    t.string   "name",                                                         :null => false
    t.string   "encrypted_password",                                           :null => false
    t.boolean  "active",                                    :default => false, :null => false
    t.string   "email",                                                        :null => false
    t.text     "description"
    t.string   "attacker_message"
    t.text     "comments"
    t.string   "gender",                      :limit => 1,                     :null => false
    t.string   "avatar"
    t.integer  "referral_id"
    t.integer  "clan_id"
    t.datetime "adjust_time"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_moderator",                              :default => false, :null => false
    t.boolean  "is_admin",                                  :default => false, :null => false
    t.boolean  "on_holiday",                                :default => false, :null => false
    t.datetime "holiday_start_time"
    t.string   "last_activity",               :limit => 50
    t.datetime "last_activity_time"
    t.integer  "a_money",                                   :default => 0,     :null => false
    t.integer  "a_staff",                                   :default => 0,     :null => false
    t.integer  "a_staff2",                                  :default => 0,     :null => false
    t.integer  "a_level",                                   :default => 0,     :null => false
    t.integer  "a_power",                                   :default => 0,     :null => false
    t.integer  "a_protection",                              :default => 0,     :null => false
    t.integer  "a_dexterity",                               :default => 0,     :null => false
    t.integer  "a_weight",                                  :default => 0,     :null => false
    t.integer  "a_skill",                                   :default => 0,     :null => false
    t.integer  "a_reputation",                              :default => 0,     :null => false
    t.integer  "a_experience",                              :default => 0,     :null => false
    t.integer  "a_health",                                  :default => 0,     :null => false
    t.boolean  "pet_active"
    t.integer  "pet_kind"
    t.integer  "pet_health",                                :default => 10
    t.integer  "pet_weight",                                :default => 15
    t.integer  "pet_skill",                                 :default => 10
    t.integer  "pet_protection",                            :default => 10
    t.integer  "pet_power",                                 :default => 10
    t.integer  "pet_dexterity",                             :default => 10
    t.integer  "patrol_money",                              :default => 0,     :null => false
    t.integer  "patrol_experience",                         :default => 0,     :null => false
    t.datetime "patrol_start_time"
    t.datetime "patrol_end_time"
    t.integer  "patrol_staff",                              :default => 0,     :null => false
    t.integer  "s_patrol_total_time",                       :default => 0,     :null => false
    t.integer  "s_wins_count",                              :default => 0,     :null => false
    t.integer  "s_loot_money",                              :default => 0,     :null => false
    t.integer  "s_patrol_time_minutes",                     :default => 0,     :null => false
    t.integer  "s_farm_time_hours",                         :default => 0,     :null => false
    t.integer  "s_loses_count",                             :default => 0,     :null => false
    t.integer  "s_lost_money",                              :default => 0,     :null => false
    t.integer  "s_kill_pets",                               :default => 0,     :null => false
    t.integer  "s_lose_pets",                               :default => 0,     :null => false
    t.integer  "s_loot_staff2",                             :default => 0,     :null => false
    t.integer  "s_lost_staff2",                             :default => 0,     :null => false
    t.integer  "s_referral_bonus_count",                    :default => 0,     :null => false
    t.integer  "s_total_damage",                            :default => 0,     :null => false
    t.integer  "g_plantation",                              :default => 0,     :null => false
    t.integer  "g_places",                                  :default => 0,     :null => false
    t.integer  "g_fence",                                   :default => 0,     :null => false
    t.integer  "g_clairvoyance",                            :default => 0,     :null => false
    t.integer  "g_cloaking",                                :default => 0,     :null => false
    t.string   "chat_room",                   :limit => 30
    t.datetime "chat_activity_time"
    t.boolean  "confirmed_email",                           :default => false, :null => false
    t.integer  "g_power",                                   :default => 0,     :null => false
    t.integer  "g_protection",                              :default => 0,     :null => false
    t.integer  "g_endudance",                               :default => 0,     :null => false
    t.datetime "g_safe_expired_at"
    t.datetime "g_safe2_expired_at"
    t.integer  "s_lost_protection",                         :default => 0,     :null => false
    t.datetime "g_power_expired_at"
    t.datetime "g_protection_expired_at"
    t.datetime "g_endurance_expired_at"
    t.integer  "active_avatar_id",                                             :null => false
    t.boolean  "active_messaging",                          :default => true,  :null => false
    t.boolean  "bounced_email",                             :default => false
    t.string   "remember_token"
    t.datetime "g_antipet_expired_at"
    t.datetime "g_pet_power_expired_at"
    t.datetime "g_pet_antikiller_expired_at"
    t.datetime "plantation_updated_at"
    t.datetime "daily_bonus_updated_at"
    t.datetime "meditation_started_at"
    t.datetime "meditation_finished_at"
    t.integer  "meditation_experience"
    t.integer  "meditation_money"
    t.integer  "s_meditation_minutes",                      :default => 0
    t.datetime "g_voodoo_expired_at"
    t.boolean  "unsubscribe",                               :default => false
    t.integer  "current_clan_war_user_id"
    t.boolean  "tutorial_done"
    t.integer  "s_sent_curses",                             :default => 0
    t.integer  "s_received_curses",                         :default => 0
    t.integer  "s_sent_gifts",                              :default => 0
    t.integer  "s_received_gifts",                          :default => 0
    t.integer  "bp_user_id"
    t.integer  "bp_affiliate_id"
    t.string   "bp_name"
    t.string   "bp_user_country"
    t.boolean  "deleted",                                   :default => false, :null => false
    t.integer  "hi5_id"
    t.integer  "fb_id",                       :limit => 8,  :default => 0,     :null => false
    t.string   "fb_email"
    t.string   "fb_name"
    t.string   "hi5_name"
    t.integer  "g_achivement_champion",                     :default => 0
    t.integer  "g_achivement_damage",                       :default => 0
    t.integer  "g_achivement_elders",                       :default => 0
    t.integer  "g_achivement_hero",                         :default => 0
    t.integer  "g_achivement_meditation",                   :default => 0
    t.integer  "g_achivement_stealer",                      :default => 0
    t.integer  "g_achivement_pet_kills",                    :default => 0
    t.integer  "g_achivement_won_wars",                     :default => 0
    t.integer  "g_achivement_dragons",                      :default => 0
    t.integer  "g_achivement_gifts",                        :default => 0
    t.integer  "s_vote",                                    :default => 0
  end

  add_index "users", ["a_level", "created_at", "last_activity_time", "on_holiday"], :name => "fight_find"
  add_index "users", ["active", "deleted", "name"], :name => "index_relations_find"
  add_index "users", ["clan_id"], :name => "index_users_on_clan_id"
  add_index "users", ["remember_token"], :name => "index_users_on_remember_token"

end

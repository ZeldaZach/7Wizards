class BigpointPaymentLog < ActiveRecord::Migration
  def self.up
    create_table "bigpoint_payment", :force => true do |t|
      t.string   "type",              :null => false
      t.integer  "amount",            :null => false
      t.string   "uniqueID",          :null => false
      t.string   "accountType",       :null => false
      t.integer  "userAmount",        :null => false
      t.string   "userAmountCurrency"
      t.integer  "userRevenue"
      t.string   "userRevenueCurrency"
      t.string   "message"
      t.integer  "transactionID"
      t.integer  "internalInfo"
      t.string   "geoCountry"
      t.integer  "accountID"
      t.integer  "subscriptionID"
      t.integer  "subscriptionDateExpires"
      t.integer  "subscriptionInterval"
      t.integer  "timestamp"

      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_column :users, :deleted, :boolean, :default => 0, :null => false
    remove_index "users",  :name => "index_relations_find"
    add_index "users", ["active", "deleted", "name"], :name => "index_relations_find"
  end

  def self.down
    remove_index "users", :name => "index_relations_find"
    add_index "users", ["active", "name"], :name => "index_relations_find"

    remove_column :users, :deleted
    drop_table :bigpoint_payment
  end
end

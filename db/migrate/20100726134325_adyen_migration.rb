class AdyenMigration < ActiveRecord::Migration
  def self.up
    create_table "adyen_notifications", :force => true do |t|
      t.boolean  "live",          :default => false, :null => false
      t.string   "event_code",    :null => false
      t.string   "psp_reference", :null => false
      t.string   "original_reference"
      t.string   "merchant_reference",  :null => false
      t.string   "merchant_account_code",  :null => false
      t.datetime "event_date",             :null => false
      t.boolean  "success",                :default => false, :null => false
      t.string   "payment_method"
      t.string   "operations"
      t.text     "reason"
      t.string   "currency",              :limit => 3,  :null => false
      t.decimal  "value",             :precision => 9, :scale => 2
      t.boolean  "processed",          :default => false, :null => false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.boolean  "compleated",          :default => false
      t.integer  "user_id"
    end
    add_index :adyen_notifications, [:psp_reference, :event_code, :success], :unique => true, :name => 'adyen_notification_uniqueness'
  end

  def self.down
    remove_index("adyen_notifications", :name => 'adyen_notification_uniqueness')
    drop_tabe :adyen_notifications
  end
end

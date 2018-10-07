class CreatePaymentLogs < ActiveRecord::Migration
  def self.up
    create_table "payment_logs", :force => true do |t|
      t.integer  "user_id",                       :null => false
      t.integer  "kind",                          :null => false
      t.string   "reason",                        :null => false
      t.integer  "amount",                        :null => false
      t.string   "description",  :size => 100,    :null => false
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end

  def self.down
    drop_table :payment_logs
  end
end

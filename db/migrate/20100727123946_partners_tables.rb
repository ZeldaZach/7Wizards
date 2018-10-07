class PartnersTables < ActiveRecord::Migration
  def self.up
    create_table :partners, :force => true do |t|
      t.string   "name", :null => false
      t.datetime "created_at"
      t.datetime "updated_at"
    end
    create_table :user_marketing_infos, :force => true do |t|
      t.integer  "user_id"
      t.integer  "partner_id"
      t.string   "source"
      t.string   "campaign_id"
      t.string   "keywords"
      t.string   "referrer"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end

  def self.down
    drop_tabe :user_marketing_infos
    drop_tabe :partners
  end
end

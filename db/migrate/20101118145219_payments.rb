class Payments < ActiveRecord::Migration
  def self.up
    add_column :payment_logs, :price, :decimal, :precision => 9, :scale => 2
    PaymentLog.update_all("price = 5.99", "amount=600 and kind = 3")
    PaymentLog.update_all("price = 17.99", "amount=2400 and kind = 3")
    PaymentLog.update_all("price = 35.99", "amount=5400 and kind = 3")
  end

  def self.down
    remove_column :payment_logs, :price
  end
end

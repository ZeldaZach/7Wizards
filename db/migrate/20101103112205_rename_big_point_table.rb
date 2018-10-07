class RenameBigPointTable < ActiveRecord::Migration
  def self.up
    rename_table(:bigpoint_payment, :bigpoint_payments)

    remove_column :bigpoint_payments, :userAmount

    rename_column(:bigpoint_payments, :uniqueID, :unique_id)
    rename_column(:bigpoint_payments, :accountType, :account_type)
    rename_column(:bigpoint_payments, :userAmountCurrency, :user_amount_currency)
    rename_column(:bigpoint_payments, :userRevenue, :user_revenue)
    rename_column(:bigpoint_payments, :userRevenueCurrency, :user_revenue_currency)
    rename_column(:bigpoint_payments, :transactionID, :transaction_id)
    rename_column(:bigpoint_payments, :internalInfo, :internal_info)
    rename_column(:bigpoint_payments, :geoCountry, :geo_country)
    rename_column(:bigpoint_payments, :accountID, :account_id)
    rename_column(:bigpoint_payments, :subscriptionID, :subscription_id)
    rename_column(:bigpoint_payments, :subscriptionDateExpires, :subscription_date_expires)
    rename_column(:bigpoint_payments, :subscriptionInterval, :subscription_interval)
    rename_column(:bigpoint_payments, :type, :payment_type)

    add_column :bigpoint_payments, :user_id, :integer, :null => false
  end

  def self.down
    
    add_column :bigpoint_payments, :userAmount, :integer

    rename_column(:bigpoint_payments, :payment_type, :type)

    rename_column(:bigpoint_payments, :unique_id, :uniqueID)
    rename_column(:bigpoint_payments, :account_type, :accountType)
    rename_column(:bigpoint_payments, :user_amount_currency, :userAmountCurrency)
    rename_column(:bigpoint_payments, :user_revenue, :userRevenue)
    rename_column(:bigpoint_payments, :user_revenue_currency, :userRevenueCurrency)
    rename_column(:bigpoint_payments, :transaction_id, :transactionID)
    rename_column(:bigpoint_payments, :internal_info, :internalInfo)
    rename_column(:bigpoint_payments, :geo_country, :geoCountry)
    rename_column(:bigpoint_payments, :account_id, :accountID)
    rename_column(:bigpoint_payments, :subscription_id, :subscriptionID)
    rename_column(:bigpoint_payments, :subscription_date_expires, :subscriptionDateExpires)
    rename_column(:bigpoint_payments, :subscription_interval, :subscriptionInterval)

    remove_column :bigpoint_payments, :user_id

    rename_table(:bigpoint_payments, :bigpoint_payment)
  end
end

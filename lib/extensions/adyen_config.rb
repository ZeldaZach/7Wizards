class AdyenConfig

  APP_ADYEN = YAML.load_file("#{RAILS_ROOT}/config/adyen.yml")[RAILS_ENV]

  def self.skin_code
    APP_ADYEN['skin_code']
  end

  def self.merchant_account
    APP_ADYEN['merchant_account']
  end

  def self.shared_secret
    APP_ADYEN['shared_secret']
  end

  def self.currency_code
    APP_ADYEN['currency_code']
  end

  def self.country_code
    APP_ADYEN['country_code']
  end

  def self.url
    APP_ADYEN['url']
  end

  def self.order_data(product)
    return "<span>#{product}</span>"
  end

  def self.get_by_key(key)
    products if @@products_hash.nil?
    @@products_hash[key]
  end

  def self.products

    return @@products if @@products && @@products_hash

    @@products = []
    @@products_hash = {}

    APP_ADYEN['products'].each_pair do |key, value|
      value[:key] = key
      @@products << value

      @@products_hash[key] = value
    end

    @@products.sort!{ |x, y| x[:key] <=> y[:key] }
  end

  @@products = nil
  @@products_hash = nil
end
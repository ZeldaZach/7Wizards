class AppProperty < ActiveRecord::Base

  validates_uniqueness_of :name
  validates_presence_of :name

  def self.exchange_staff_to_money_rate
    get_number_value('exchange_staff_to_money_rate', GameProperties::EXCHANGE_STAFF_TO_MONEY_DEFAULT_RATE)
  end

  def self.exchange_staff_to_money_rate=(value)
    set_value('exchange_staff_to_money_rate', value)
  end

  def self.exchange_staff2_to_staff_rate
    get_number_value('exchange_staff2_to_staff_rate', GameProperties::EXCHANGE_STAFF2_TO_STAFF_DEFAULT_RATE)
  end

  def self.exchange_staff2_to_staff_rate=(value)
    set_value('exchange_staff2_to_staff_rate', value)
  end

  private

  def self.get_number_value(name, default = 0)
    r = get_value(name, nil)
    r ? r.to_i : default
  end

  def self.get_value(name, default = '')
    r = find_by_name(name)
    r ? r.value : default
  end

  def self.set_value(name, value)
    r = find_by_name(name)
    r = AppProperty.new( :name => name)  if !r
    r.value = value.to_s
    r.save!
  end

end

class PaymentLog < ActiveRecord::Base
  
  # include base mode behaviour
  include Helpers::TranslateHelper
  
  ADD_BONUS = 1
  SPEND_STAFF = 2
  BUY_STAFF = 3

  belongs_to :user

  def self.add_staff(user, amount, reason, description, kind = ADD_BONUS, price_value = nil)
    PaymentLog.create! :user => user,
      :amount => amount,
      :kind => kind,
      :reason => reason,
      :description => description,
      :price => price_value
  end

  def self.spend_staff(user, amount, reason, description)
    PaymentLog.create! :user => user,
      :amount => amount,
      :kind => SPEND_STAFF,
      :reason => reason,
      :description => description
  end

  def self.user_payments(user, page = 1)
    PaymentLog.paginate :conditions => {:user_id => user.id, :kind => SPEND_STAFF}, :order => "created_at DESC", :page => page, :per_page => per_page
  end

  def self.get_last_dailybonus(user)
    find :last, :conditions => {:user_id => user.id, :kind => ADD_BONUS}
  end

  def title

    item = AllUserItems.find_by_key self.reason
    if item.nil?
      item = AllGameItems.get self.reason
    end

    t = item.title if item
    t = translate(self.description, :scope => [:user_items]) unless t
    t
  end

end

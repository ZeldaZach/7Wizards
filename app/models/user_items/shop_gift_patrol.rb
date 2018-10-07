class UserItems::ShopGiftPatrol < UserItems::ShopGift

  # Envelope of Wealth
  # Income from meditation: +20%

  def self.apply_money(user)
    user.meditation_money = apply_custom_percent(user, user.meditation_money)
  end
  
end

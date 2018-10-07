class UserItems::ShopGiftHousePowerProtection < UserItems::ShopGift

  # Royal Crown
  # Power crystal and defence powder: +20%

  def self.get_power_and_protection_percent(user)
    get_custom_percent(user)
  end

end

class UserItems::ShopGiftLootMoney < UserItems::ShopGift

  # Blessing Powder
  # The amount of mana robbed on the arena will be increased by 50%
  
  def self.get_money_receive_percent(user, percent)
    value = get_custom_percent(user).to_percent
    percent * (1 + value)
  end

end

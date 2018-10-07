class UserItems::ShopGiftWarHidden < UserItems::ShopGift

  # Ancient Guard
  # Immortality during the war

  def self.hidden_on_war?(user)
    is_custom_active?(user)
  end

end
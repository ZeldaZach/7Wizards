class UserItems::ShopCurseAntiGift < UserItems::ShopCurse

  # Toxic Pie
  # The opponent won't be able to receive gifts

  def self.active?(user)
    is_custom_active?(user)
  end
  
end

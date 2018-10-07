class UserItems::ShopCurseAntiHousePowerProtection < UserItems::ShopCurse

  # Fiend's Horn
  # Power crystal and defence powder will be disabled

  def self.active?(user)
    is_custom_active?(user)
  end

end
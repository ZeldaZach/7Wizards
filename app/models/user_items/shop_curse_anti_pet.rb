class UserItems::ShopCurseAntiPet < UserItems::ShopCurse

  # Killing Trap
  # The pet heart cage will be disabled with the 5% possibility

  def self.fired?(user)
    is_custom_fired?(user)
  end

end

class UserItems::ShopCursePatrol < UserItems::ShopCurse

  # Beast Scraps
  # The income from meditation will be 0 with the 20% possibility

  def self.fired?(user)
    is_custom_fired?(user)
  end

end
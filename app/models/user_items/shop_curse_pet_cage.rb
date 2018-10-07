class UserItems::ShopCursePetCage < UserItems::ShopCurse

  # Evil Skull
  # The opponent's pet will be sent to the cage and locked there

  # override
  def send_present
    Services::PetService.set_pet_lock user do
      if user.pet_active?
        Services::PetService.activate_pet user, false, :message_key => :deactivate_pet_curse
      end
    end
  end

  def self.active?(user)
    is_custom_active?(user)
  end

end

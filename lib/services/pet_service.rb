class Services::PetService

  def self.set_pet_lock(user)
    RedisLock.lock "user_pet_lock_#{user.id}" do
      yield
    end
  end

  # we can activate or deactivate pet using this method
  # it will return true in case of success and false otherwise
  def self.activate_pet(user, value, options = {})
    if user.pet_active != value
      user.transaction do
        user.pet_active = value
        user.save!

#        Message.create_pet_event user, value, options[:message_key]

        return true
      end
    end
    false
  end

end

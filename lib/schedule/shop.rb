class Schedule::Shop < Schedule::Base

  def self.check
    check_expired_items             # mark expired items to be removed
    remove_non_used_expired_items   # remove old expired items
    remove_old_non_used_items       # remove old non used items
  end

  def self.check_expired_items
    UserItem.update_all("user_id = -user_id", ['user_id > ? and active_till < ?', 0, Time.new])
  end

  def self.remove_non_used_expired_items
    # we store expired items several days just to be able to handle support tickets
    UserItem.destroy_all ['user_id < ? and active_till < ?', 0, 3.days.ago]
  end

  def self.remove_old_non_used_items
    # we store non used items several days to be able to handle support tickets
    UserItem.destroy_all ['user_id < ? and updated_at < ?', 0, 5.days.ago]
  end

  self.redefine(self)

end
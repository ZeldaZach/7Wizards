class AchivementGifts < AbstractAchivement
  KEY = 'gifts'

  def gift_extend!(user, friend, value = 1)
    return if user.sent_gifts_count(friend) > 1
    extend(user, value)
    user.save!
  end

end

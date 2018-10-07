class UserItems::ShopCurseFightParameters < UserItems::ShopCurse

  # Witch Bag
  # All battle stats: -10%

  def self.apply_user_attributes(user, user_attributes)

    percent = get_custom_percent(user)
    return if percent == 0

    apply_attribute = proc do |name|
      attr = "curses_#{name}"
      value = user_attributes.send("a_#{name}")     # get user attribute
      value = (value * percent.to_percent).to_i     # apply curse percent on attribute value
      value += user_attributes.send(attr) || 0      # add value to curses attributes
      user_attributes.send("#{attr}=", value)      
    end

    apply_attribute.call :protection
    apply_attribute.call :power
    apply_attribute.call :dexterity
    apply_attribute.call :skill
  end

end
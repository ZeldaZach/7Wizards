class ProfileRules < AbstractRules

  def self.can_train_attribute(user, attribute)

    r = Rule.new

    if !attribute
      r.message = tg :strange_situation
      return r
    end

    value = user['a_' + attribute]

    if !value
      r.message = tg :strange_situation
      return r
    end

    price = UserAttributesGrowthTable.get_price(user, attribute.intern)

    if !price || price == 0
      r.message = tg :strange_situation
      return r
    end

    if user.a_money < price
      r.message = t :not_enought_money
      return r
    end

    r
  end

  def self.can_use_item(user, item, options = {})
    r = Rule.new

    if !item
      r.message = tg :strange_situation
      return r
    end

    return item.can_use?(user, options)
  end

  def self.can_takeoff_item(user, item)
    r = Rule.new

    if !item
      r.message = tg :strange_situation
      return r
    end

    return item.can_takeoff?(user)
  end

  def self.can_change_email(user, email)
    r = Rule.new

    if user.email == email
      r.message = t :email_should_be_new
      return r
    end

    if  !(/^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i =~ email)
      r.message = "Not valid"
      return r
    end

    em = User.find_by_email(email)
    unless em.nil?
      r.message = t :email_already_taken
      return r
    end
    r
  end

  def self.can_edit_descriptions(user)
    r = Rule.new
    if user.a_level < GameProperties::MIN_LEVEL_TO_EDIT_MESSAGES
      r.message = tg :required_min_level, :min => GameProperties::MIN_LEVEL_TO_EDIT_MESSAGES
      return r
    end
    r

  end

  def self.can_extend(user, item)
    r = Rule.new

    if !item
      r.message = tg :strange_situation
      return r
    end

    item.can_extend?(user)
  end

  def self.can_vote(voter, user)
    r = Rule.new
    if(user.nil? || voter.nil?)
      r.message = tg :strange_situation
      return r
    end

    if AvatarVoting.voter_user_today_count(voter, user) > 0
      r.message = t :already_voted_today
      return r
    end

    if AvatarVoting.voter_today_count(voter) >= GameProperties::AVATAR_VOTING_PER_DAY_MAX
      r.message = t :voting_reached_max, :max => GameProperties::AVATAR_VOTING_PER_DAY_MAX
      return r
    end

    if voter.a_level < GameProperties::AVATAR_VOTING_MIN_LEVEL
      r.message = tg :required_min_level, :min => GameProperties::AVATAR_VOTING_MIN_LEVEL
      return r
    end

    r
  end
  
end

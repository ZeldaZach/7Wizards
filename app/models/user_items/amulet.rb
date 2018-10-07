class UserItems::Amulet < UserItems::AbstractLevelUserItem

  CATEGORY = :amulet

  TYPE_FIGHT = 'f'
  TYPE_WORK = 'w'
  TYPE_OTHER = 'o'

  def for_pet?
    self.class.for_pet?
  end

  class << self

    def self.type
      self::TYPE
    end

    def for_pet?
      @config_pet == true
    end

    # needed for acts_like calls
    def acts_like_amulet?
      true
    end

    def can_buy?(user)
      r = super(user)
      return r unless r.allow?

      unless check_requirements(user)
        r.message = requirements 
        return r
      end

      r
    end

    # override
    def can_use?(user, options = {})
      r = super(user, options)
      return r if !r.allow?
      
      used_amulets = for_pet? ? user.used_pet_amulets : user.used_amulets
      max = GameProperties::USER_MAX_USED_AMULETS
      if used_amulets.length >= max
        r.message = tr(for_pet? ? :already_used_pet_amulets : :already_used_amulets,
          :max => max
        )
        return r
      end

      r
    end

    # override
    def required_level
      1 # for amulets it's always 1
    end

    # check if cullon executed, #1 method used to check if colon did it's job
    def used?(user)
      get_percent(user) > rand
    end

    # will return total percent in percents
    def get_percent(user)
      get_used_percent(user).to_percent
    end

    # in percents, #2 method used to check if colon did it's job
    # result is in range 0..100
    def get_used_percent(user)
      return 0 if !user.uses_item?(self)
      get_used_percent_value(user)
    end

    # the same as get_percent but do not check it user uses this item at the moment
    # result is in range 0..100
    def get_used_percent_value(user)
      l = get_level(user)
      get_level_percent(l)
    end

    # result is in range 0..100
    def get_level_percent(level)
      r = 0
      r = @config_initial_percent + @config_level_percent * (level - 1) if level > 0
      r
    end

    # override
    def description(user=nil)
      l = user ? get_level(user) : 0
      @config_description.gsub /\{\{percent\}\}/, get_level_percent(l).to_s
    end

    # override
    def next_description(user=nil)
      l = user ? get_level(user) : 0
      l >= get_max_level ? nil : @config_next_description.gsub(/\{\{percent\}\}/, get_level_percent(l + 1).to_s)
    end

    def requirements
      @config_requirements
    end

    # to buy amulet this method should return true
    def check_requirements(user)
      true
    end

    #do we need show button BUY
    #override
    def button_buy?(user = nil)
      !self.has?(user)
    end

    #do we need show button EXTEND
    #override
    def button_extend?(user = nil)
      self.has?(user) && self.get_max_level > self.get_level(user)
    end

  end

#  def max_level?(user)
#    get_level(user) >= max_level
#  end

#  def description(user_or_item = nil, level_increment = 0, local_key = 'description')
#    if user_or_item.is_a?(User)
#      user = user_or_item
#      if has_item?(user)
#        l = get_level(user) + level_increment
#        return level_description(l, local_key)
#      end
#    end
#    if user_or_item.is_a?(UserItem)
#      item = user_or_item
#      l = item.level + level_increment
#      return level_description(l, local_key)
#    end
#
#    percent = initial_percent
#    translate("other.amulet.#{key}.#{local_key}", :percent => percent.to_f)
#  end

#  def next_level_description(user = nil)
#    description(user, 1, 'next_level_description')
#  end
#
#  def level_description(level, local_key = 'description')
#    percent = get_level_percent(level)
#    percent *= 100
#    translate("other.amulet.#{key}.#{local_key}", :percent => percent.to_f)
#  end

end


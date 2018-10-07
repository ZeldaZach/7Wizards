#serialized in redis
class UserExt::UserAttributes

  attr_accessor :name, :user_id, :avatar, :gender, :clan_name, :clan_id, :used_items, :used_gifts, :used_curses,
    :a_level, :a_money, :a_staff, :a_power, :a_protection, :a_dexterity,
    :a_weight, :a_skill, :a_reputation, :a_experience, :a_health,
    :items_power, :items_protection, :items_dexterity, :items_skill, :items_weight,
    :gifts_power, :gifts_protection, :gifts_dexterity, :gifts_skill, :gifts_weight,
    :curses_power, :curses_protection, :curses_dexterity, :curses_skill, :curses_weight,
    :gifts_game_power, :gifts_game_protection, :curses_game_power, :curses_game_protection,
    :game_power, :game_protection, :game_fence_protection, :game_safe, :game_endurance,
    :game_pet_power, :game_antipet, :game_pet_antikiller, :game_voodoo,
    :full_power, :full_protection, :full_dexterity, :full_skill, :full_weight,
    :pet_active, :pet_kind, :pet_avatar, :pet_power, :pet_protection,
    :pet_dexterity, :pet_weight, :pet_skill, :pet_health,
    :pet_kill_skill_bonus, :full_pet_power, :full_pet_skill,
    :clan_power, :clan_protection, :user_items, :confirmed_email, :bigpoint


  def initialize(user = nil, options = {})
    if (user)
      @user_id = user.id
      @name = user.name
      @avatar = user.avatar
      @gender = user.gender
      @confirmed_email = user.confirmed_email # TODO, seems we should deliver this fix on prod asap because we need to update all saved user attributes before we release dragons !!!
      @bigpoint = user.bigpoint?
      
      if user.clan
        @clan_name = user.clan.name
        @clan_id = user.clan.id
      end

      @a_level = user.a_level
      @a_money = user.a_money
      @a_staff = user.a_staff
      @a_power = user.a_power
      @a_protection = user.a_protection
      @a_dexterity = user.a_dexterity
      @a_weight = user.a_weight
      @a_skill = user.a_skill
      @a_reputation = user.a_reputation
      @a_experience = user.a_experience
      @a_health = user.a_health
      
      @user_items = []
      @used_items = user.used_clothes_items
      @used_items.each do |item|
        item.apply self
        @user_items << item.key
      end

      user.used_amulets.each do |item|
        @user_items << item.key
      end

      @used_gifts = user.used_gifts
      @used_gifts.each do |item|
        item.apply self
        @user_items << item.key
      end

      @used_curses = user.used_curses
      @used_curses.each do |item|
        item.apply self
        @user_items << item.key
      end

      # apply fight curse
      UserItems::ShopCurseFightParameters.apply_user_attributes(user, self)

      @full_power = @a_power
      @full_power += @items_power if @items_power
      @full_power += @gifts_power if @gifts_power

      if AllGameItems::POWER.is_active? user
        @game_power = AllGameItems::POWER.get_power(user, @full_power)
      end

      if user.clan && AllClanItems::POWER.is_active?(user.clan)
        @clan_power = AllClanItems::POWER.get_power(user.clan, @full_power)
      end

      @full_protection =  @a_protection
      @full_protection += @items_protection if @items_protection
      @full_protection += @gifts_protection if @gifts_protection

      if AllGameItems::PROTECTION.is_active? user
        @game_protection = AllGameItems::PROTECTION.get_protection(user, @full_protection)
      end

      # we should not apply fence to user who is attacking
      if !options[:fight_user] && AllGameItems::FENCE.is_active?(user)
        @game_fence_protection = AllGameItems::FENCE.get_protection(user, @full_protection)
      end

      if user.clan && AllClanItems::PROTECTION.is_active?(user.clan)
        @clan_protection = AllClanItems::PROTECTION.get_protection(user.clan, @full_protection)
      end

      # if we have druid power or protection then we should check druid gift
      if @game_power || @game_protection
        gift_percent = UserItems::ShopGiftHousePowerProtection.get_power_and_protection_percent(user)

        @gifts_game_power = (gift_percent.to_percent * @game_power).to_i if @game_power
        @gifts_game_protection = (gift_percent.to_percent * @game_protection).to_i if @game_protection

        if UserItems::ShopCurseAntiHousePowerProtection.active?(user)
          @curses_game_power = -@game_power if @game_power
          @curses_game_protection = -@game_protection if @game_protection
        end
      end

      # apply power bonuses
      @full_power += @clan_power if @clan_power
      @full_power += @game_power if @game_power

      # apply protection bonuses
      @full_protection += @clan_protection if @clan_protection
      @full_protection += @game_protection if @game_protection
      @full_protection += @game_fence_protection if @game_fence_protection

      # apply skill bonuses
      @full_skill = @a_skill
      @full_skill += @items_skill if @items_skill
      @full_skill += @gifts_skill if @gifts_skill

      # apply weight bonuses
      @full_weight = @a_weight
      @full_weight += @items_weight if @items_weight
      @full_weight += @gifts_weight if @gifts_weight

      # apply dexterity bonuses
      @full_dexterity = @a_dexterity
      @full_dexterity += @items_dexterity if @items_dexterity
      @full_dexterity += @gifts_dexterity if @gifts_dexterity

      @game_safe = true if AllGameItems::SAFE.is_active?(user)
      #      @game_safe = AllGameItems.POWER.SAFE2.is_active?(user)

      @game_endurance = true if AllGameItems::ENDURANCE.is_active? user

      @game_voodoo = true if AllGameItems::VOODOO.is_active? user

      @pet_active = user.pet_active?
      @pet_kind = user.pet_kind
      @pet_power = user.pet_power
      @pet_protection = user.pet_protection
      @pet_dexterity = user.pet_dexterity
      @pet_weight = user.pet_weight
      @pet_skill = user.pet_skill
      @pet_health = user.pet_health

      @full_pet_skill = @pet_skill
      @pet_kill_skill_bonus = user.pet_kill_skill_bonus if user.pet_kill_skill_bonus > 0

      # apply pet skill bonuses
      @full_pet_skill += @pet_kill_skill_bonus if @pet_kill_skill_bonus

      # apply pet power bonuses
      if AllGameItems::PET_POWER.is_active? user
        @game_pet_power = AllGameItems::PET_POWER.get_power(user, @pet_power)
      end

      @full_pet_power = @pet_power
      @full_pet_power += @game_pet_power if @game_pet_power

      @game_antipet = AllGameItems::ANTIPET.is_active?(user)
      @game_pet_antikiller = AllGameItems::ANTIKILLER.is_active?(user)
      
    end
  end

  def get_value(v)
    self.send(v)
  end

  def get_pet_value(v)
    @pet_active ? self.send(v) : "-"
  end

  def a_staff_label
    r = self.a_staff || 0
    "#{r}"
  end

  def full_pet_power_label
    get_full_attribute_label(@pet_power, @full_pet_power)
  end

  def full_pet_skill_label(public = true)
    if public
      # it's different because we don't show bonus for all users
      @full_pet_skill ? @full_pet_skill : @pet_skill
    else
      get_full_attribute_label(@pet_skill, @full_pet_skill)
    end
  end

  def full_power_label
    get_full_attribute_label(@a_power, @full_power)
  end

  def full_protection_label
    get_full_attribute_label(@a_protection, @full_protection)
  end

  def full_dexterity_label
    get_full_attribute_label(@a_dexterity, @full_dexterity)
  end

  def full_skill_label
    get_full_attribute_label(@a_skill, @full_skill)
  end

  def full_weight_label
    get_full_attribute_label(@a_weight, @full_weight)
  end

  def pet_active?
    @pet_active == true
  end

  def monster?
    !@monster_kind.nil?
  end

  def dragon?
    false
  end

  def bigpoint?
    @bigpoint
  end

  def curses_power_all
    r = 0
    r += curses_power if curses_power
    r += curses_game_power if curses_game_power
    r
  end

  def curses_protection_all
    r = 0
    r += curses_protection if curses_protection
    r += curses_game_protection if curses_game_protection
    r
  end

  def gifts_power_all
    r = 0
    r += gifts_power if gifts_power
    r += gifts_game_power if gifts_game_power
    r
  end

  def gifts_protection_all
    r = 0
    r += gifts_protection if gifts_protection
    r += gifts_game_protection if gifts_game_protection
    r
  end

  def md5
    h  = @a_level.to_s
    h << @full_power.to_s
    h << @full_protection.to_s
    h << @full_dexterity.to_s
    h << @full_skills.to_s
    h << @full_weight.to_s
    h << @pet_active.to_s
    Digest::MD5.hexdigest(h)
  end

  private

  def get_full_attribute_label(value, full_value)
    if full_value
      if full_value > value
        return "#{value}+#{full_value - value}"
      end
      if full_value < value
        return "#{value}#{full_value - value}"
      end
    end
    "#{value}"
  end

end

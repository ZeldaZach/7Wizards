class UserItems::ShopCloses < UserItems::AbstractShopUserItem

  HELMET_CATEGORY = :helmet
  WEAPON_CATEGORY = :weapon
  ARMOUR_CATEGORY = :armour
  SHIELD_CATEGORY = :shield

  def apply(user)
    self.class.apply(user)
  end

  class << self

    include Helpers::FormattingHelper

    # override
    def description(user=nil)
      r = super
      if r.blank?
        r = ''
        r += "#{tf(User, :a_power)}: #{np(@config_power)}<br />" if @config_power
        r += "#{tf(User, :a_dexterity)}: #{np(@config_dexterity)}<br />" if @config_dexterity
        r += "#{tf(User, :a_protection)}: #{np(@config_protection)}<br />" if @config_protection
        r += "#{tf(User, :a_skill)}: #{np(@config_skill)}<br />" if @config_skill
        r += "#{tf(User, :a_weight)}: #{np(@config_weight)}<br />" if @config_weight
      end
      r
    end

    def apply(user)
      if @config_protection
        user.items_protection ||= 0
        user.items_protection += @config_protection
      end

      if @config_power
        user.items_power ||= 0
        user.items_power += @config_power
      end

      if @config_dexterity
        user.items_dexterity ||= 0
        user.items_dexterity += @config_dexterity
      end

      if @config_skill
        user.items_skill ||= 0
        user.items_skill += @config_skill
      end

      if @config_weight
        user.items_weight ||= 0
        user.items_weight += @config_weight
      end
    end

  end

end

class TutorialGifts < AbstractTutorial

  NAME = "gifts"

  def initialize
    super NAME, GameProperties::TUTORIAL_PRICE
  end

  def is_done?(user)
    r = super
    r || user.reasigned_items.all_reasigned(UserItems::ShopGift::CATEGORY).size > 0
  end

end

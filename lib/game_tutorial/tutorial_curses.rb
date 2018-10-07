class TutorialCurses < AbstractTutorial

  NAME = "curses"

  def initialize
    super NAME, GameProperties::TUTORIAL_PRICE
  end

  def is_done?(user)
    r = super
    r || user.reasigned_items.all_reasigned(UserItems::ShopCurse::CATEGORY).size > 0
  end

end

class TutorialDressup < AbstractTutorial

  NAME = "dressup"

  def initialize
    super NAME, GameProperties::TUTORIAL_PRICE
  end

  def is_done?(user)
    r = super
    r || user.avatar == 'custom'
  end

end


class TutorialMeditation < AbstractTutorial

  NAME = "meditation"

  def initialize
    super NAME, GameProperties::TUTORIAL_PRICE
  end

  def is_done?(user)
    r = super
    r || user.s_meditation_minutes > 0
  end

end


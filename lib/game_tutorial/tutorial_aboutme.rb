class TutorialAboutme < AbstractTutorial

  NAME = "aboutme"

  def initialize
    super NAME, GameProperties::TUTORIAL_PRICE
  end

  #fake task
  def is_done?(user)
    r = super
    r || !user.description.blank?
  end

end



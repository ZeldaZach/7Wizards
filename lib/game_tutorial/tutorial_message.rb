class TutorialMessage < AbstractTutorial

  NAME = "message"

  def initialize
    super NAME, GameProperties::TUTORIAL_PRICE
  end

end

class TutorialBlog < AbstractTutorial

  NAME = "blog"

  def initialize
    super NAME, GameProperties::TUTORIAL_PRICE
  end

end


class TutorialAdditionaltalents < AbstractTutorial

  NAME = "additional_talents"

  def initialize
    super NAME, GameProperties::TUTORIAL_PRICE
  end

  def is_done?(user)
    r = super
    has = false
    AllGameItems::PROFILE.each do |item|
      has = true if item.get_level(user) > 0
    end
    r || has
  end

end


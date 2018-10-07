class TutorialPowerups < AbstractTutorial

  NAME = "powerups"

  def initialize
    super NAME, GameProperties::TUTORIAL_PRICE
  end

  def is_done?(user)
    r = super
    has = false
    AllGameItems::POWER_UP.each do |item|
      has = true if item.has_item?(user)
    end
    r || has
  end

end

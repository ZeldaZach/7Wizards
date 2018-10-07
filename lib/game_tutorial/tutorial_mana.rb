class TutorialMana < AbstractTutorial

  NAME = "mana"

  def initialize
    super NAME, 0
  end

  #fake task
  def is_done?(user)
    true
  end

end


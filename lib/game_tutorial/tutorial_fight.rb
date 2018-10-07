class TutorialFight < AbstractTutorial

  NAME = "fight"

  def initialize
    super NAME, GameProperties::TUTORIAL_PRICE
  end

  def is_done?(user)
    r = super
    f = FightLog.get_last_fight(user)
    r || !f.nil?
  end

end

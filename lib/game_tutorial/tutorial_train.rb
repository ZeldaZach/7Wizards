class TutorialTrain < AbstractTutorial

  NAME = "train"

  def initialize
    super NAME, GameProperties::TUTORIAL_PRICE
  end

  def is_done?(user)
    r = super
    trained = false
    %w(a_power a_protection a_dexterity a_skill a_weight).each do |skill|
      trained = true if user[skill] > 5
    end
    r || trained
  end

  def description
    super({:mana => GameProperties::USER_INITIAL_MONEY})
  end

end


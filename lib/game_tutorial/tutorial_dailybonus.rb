class TutorialDailybonus < AbstractTutorial

  NAME = "dailybonus"

  def initialize
    super NAME, GameProperties::TUTORIAL_PRICE
  end

  def is_done?(user)
    r = super
    b = PaymentLog.get_last_dailybonus(user)
    r || !b.nil?
  end

end


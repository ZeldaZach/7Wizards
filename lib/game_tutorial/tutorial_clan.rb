class TutorialClan < AbstractTutorial

  NAME = "clan"

  def initialize
    super NAME, GameProperties::TUTORIAL_PRICE
  end

  def is_done?(user)
    r = super
    r || !user.clan.nil?
  end

end


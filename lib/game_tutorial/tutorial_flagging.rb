class TutorialFlagging < AbstractTutorial

  NAME = "flagging"

  def initialize
    super NAME, GameProperties::TUTORIAL_PRICE
  end

  def is_done?(user)
    r = super
    r || Relation.count_by_kind_and_user(Relation::KIND_BOOKMARK, user) > 0
  end

end

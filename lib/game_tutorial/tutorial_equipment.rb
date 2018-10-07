class TutorialEquipment < AbstractTutorial

  NAME = "equipment"

  def initialize
    super NAME, GameProperties::TUTORIAL_PRICE
  end

  def is_done?(user)
    r = super
    #floor ring item in use
    r || user.uses_item?("a1")
  end

  def done!(user, options = {})
    if options[:item_key].nil? || options[:item_key] == "a1"
      super
    end
    false
  end

end



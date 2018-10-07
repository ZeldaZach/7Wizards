class Schedule::All < Schedule::Base

  def self.check
    Schedule::War.check
    #    Schedule::QuestCheck.check
    Schedule::DragonPlanner.check
    Schedule::Shop.check
    #    Schedule::Farrier.check
  end

  self.redefine(self)
end

class TutorialLastTask < AbstractTutorial
  
  NAME = "receive_gift"

  def initialize
    super NAME, 0
  end

  def done!(user, options = {})
    return if user.tutorial_done 

    if !has?(user)
      
      item = AllUserItems.find_by_key "p1"
      item.add user

      user.tutorial_done = true

      add user
      user.save!

      clear_accept_task(user)
    end
  end
end

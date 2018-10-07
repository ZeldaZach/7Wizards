class AchivementElders < AbstractAchivement

  KEY = "elders"

  def can_extend?(user)
    user.tutorial_done && get_level(user) == 0
  end

  def in_progress_description(user)
    "#{get_current_scale(user)} / 1"
  end

end

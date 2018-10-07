class AchivementMeditation < AbstractAchivement

  KEY = "meditation"

  def get_current_scale(user)
    #meditation g in minutes
    m = super
    m/60
  end

end

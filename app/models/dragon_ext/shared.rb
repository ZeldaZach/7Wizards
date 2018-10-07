# shared properties between dragon attributes and dragon model

module DragonExt::Shared

  def dragon?
    true
  end

  def virtual?
    true
  end

  def monster?
    false
  end

  def quest_monster?
    false
  end

  def mercenary?
    false
  end

  def active?
    arrived_at < Time.now && Time.now < leave_at && !killed? && !left?
  end

  def killed?
    killed == true
  end

  def left?
    flew == true
  end

  def leave_at
    arrived_at + GameProperties::DRAGON_TIME
  end

  # dragon has no pet :)
  def pet_active?
    false
  end

  def confirmed_email
    true
  end

  def has_avatar?(key)
    true
  end

  def time_left
    leave_at - Time.now
  end

end

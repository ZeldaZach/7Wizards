class Rule

  def initialize(allow = true, message = nil)
    @allow = allow
    @message = message
  end

  def allow?()
    @allow
  end

  def allow=(value)
    @allow = value
  end

  def message()
    @message
  end

  def message=(value)
    @message = value
    @allow = false
  end

end

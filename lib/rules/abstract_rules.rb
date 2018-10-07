class AbstractRules

  include Helpers::TranslateHelperStatic

  # instance methods here ...

  def self.t(rule_name, options = {})
    key = "rules.#{self.to_s.gsub(/::/, '.').downcase}.#{rule_name.to_s}"
    translate(key, options)
  end

end

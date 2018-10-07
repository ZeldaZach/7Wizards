require 'new_relic/agent/method_tracer'

module BaseModel
  include NewRelic::Agent::MethodTracer

  def self.included(klass)
    klass.extend ClassMethods
  end

  def select_value(sql)
    self.connection.select_value( sql )
  end
  add_method_tracer :select_value, 'ActiveRecord/#{self.class.name}/select_value', :metric => false

  def select_values(sql)
    self.connection.select_values( sql )
  end
  add_method_tracer :select_values, 'ActiveRecord/#{self.class.name}/select_values', :metric => false

  def select_rows(sql)
    self.connection.select_rows( sql )
  end
  add_method_tracer :select_values, 'ActiveRecord/#{self.class.name}/select_rows', :metric => false

  # instance methods here ...

  module ClassMethods

    include Helpers::TranslateHelper

    # class methods here
    def t(local_key, options = {})
      key = self.name.underscore
      key = "models.#{key}.#{local_key}"
      translate key, options
    end

    def h(text)
      ERB::Util.h(text)
    end

    def user_name(user, options = {})
      name = h(user.name)
      options[:short_name] ? name[0..14] : name
    end

    def te(local_key, options = {})
      key = "activerecord.errors.messages.#{local_key}"
      translate key, options
    end

    # default per page for pagination
    def per_page
      20
    end

    # works correctly only with array conditions
    def add_conditions(options, conditions)
      if options[:conditions]
        c = options[:conditions]
        c[0] += " AND (#{conditions[0]})"
        (1..conditions.length - 1).to_a.each do |i|
          c << conditions[i]
        end
      else
        options[:conditions] = conditions
      end
    end
  end
  
end

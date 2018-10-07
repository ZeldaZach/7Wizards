require 'set'

module ActiveRecord::Deltas
  def self.included(klass)
    klass.class_eval do
      alias_method_chain :attributes_with_quotes, :deltas
    end
  end
  
  def attributes_with_quotes_with_deltas(*args)
    with_deltas = attributes_with_quotes_without_deltas(*args)
    return with_deltas if self.new_record?
    with_deltas.keys.each do |attribute_name|
      if self.class.delta_attributes.include?(attribute_name.intern) && !self.excluded_deltas.include?(attribute_name.intern)
        delta_string = "#{self.connection.quote_column_name(attribute_name)} "
        old_value, new_value = self.changes[attribute_name]
        delta_string << (old_value > new_value ? "-" : "+")
        delta_string << " #{(old_value - new_value).abs}"
        with_deltas[attribute_name] = delta_string
      end
    end
    with_deltas
  end

  def excluded_deltas
    @_excluded_deltas ||= Set.new
  end
  
  def force_clobber(attr_name, value)
    self.excluded_deltas.add(attr_name.to_s.intern)
    send("#{attr_name}=", value)
  end
end

class ActiveRecord::Base
  include ActiveRecord::Deltas
  class InvalidDeltaColumn < StandardError; end
  def self.delta_attributes(*args)
    @_delta_attributes ||= Set.new
    
    return @_delta_attributes if args.empty?
    
    args.each do |attribute|
      raise InvalidDeltaColumn.new("Delta attributes only work with number attributes, column `#{attribute}` is not a number.") unless self.columns_hash[attribute.to_s].number?
      @_delta_attributes.add(attribute)
    end
  end  
end
class BaseOhmModel < Ohm::Model

  include ::Helpers::TranslateHelper
  include ::Ext::GeneratedMessage

  #override
  def initialize(attributes = {})
    self.class.remap(attributes)
    super
  end

  def self.create(*args)
    update_base_attributes(args.first)
    super
  end

  def save
    update_attributes({:updated_at_s => Time.new.to_i})
    super
  end

  def self.attribute_ref(name)
    self.attribute("#{name}_id".to_sym)

    define_method(name) do
      read_active_record(name)
    end

    define_method("#{name}=") do |arg|
      write_active_record(name, arg)
    end
  end

  def self.attribute_time(name)
    self.attribute("#{name}_s".to_sym)

    define_method(name) do
      read_time_record(name)
    end
  end

  def self.index_ref(att)
    index "#{att}_id".to_sym
  end

  def assert_present_ref(att, error = [att, :not_present])
    assert_present("#{att}_id".to_sym, error)
  end

  #OVERRIDE 
  def id
    @id
  end
  
  def id=(v)
    @id = v
  end

  #override
  def self.find(hash)
    r = super remap(hash)
    WrapCollection.new(r)
  end

  # Warpper for Collection, need for override method sort_by
  class WrapCollection < Ohm::Model::Collection
    Raw = Ohm::Set
    
    def initialize(raw)
      super raw.key, Ohm::Model::Wrapper.wrap(raw.model)
    end

    def sort_by(att, options = {})
      super replace_times_key(att), options
    end
    
    def replace_times_key(attr)
      return :created_at_s if attr.to_s == "created_at"
      return :updated_at_s if attr.to_s == "updated_at"
      attr
    end
  end

  protected
  
  def self.remap(attr = {})

    attr.each do |key, model|
      populate_model(attr, key, model)
    end

  end

  #get ActiveRecord from database by mid
  #Example
  #Object::const_get(m[:class_name]).find(m[:mid]) -> User.find(m[:mid])
  def read_active_record(name)
    value = @_attributes["#{name}_id".to_sym]
    
    if is_marshal(value)
      if @cache == value && @model
        return @model
      end
      
      @cache = value
      m = Marshal.load value
      if(m[:mid] && m[:class_name])
        value = Object::const_get(m[:class_name]).find_by_id(m[:mid])
        @model = value
      end 
    end
    value
  end

  def write_active_record(name, value)
    self.class.populate_model(attributes, name, value)
  end

  def self.populate_model(attr, key, model)
    if model && model.is_a?(ActiveRecord::Base)

      key_id = "#{key}_id".to_sym

      raise "Attribute #{key_id} does not exists" if !attributes.include?(key_id)

      attr[key_id] = Marshal.dump({:mid => model.id, :class_name => model.class.name})
      attr.delete(key)
    end

    if [:created_at, :updated_at].include?(key)
      attr[replace_times_key(key)] = model
      attr.delete(key)
    end
  end

  def read_time_record(name)
    value = @_attributes["#{name}_s".to_sym]
    Time.at(value.to_i)
  end

  #Check is marshal data
  def is_marshal(obj)
    return false if obj.nil?

    data = obj.to_s
    major = data[0]
    minor = data[1]
    
    if major != Marshal::MAJOR_VERSION or minor > Marshal::MINOR_VERSION then
      return false
    end
    true
  end

  def self.time_stamps
    attribute_time :created_at
    attribute_time :updated_at
  end

  def self.update_base_attributes(options)
    #need store datetime in integer for correct sorting
    options[:created_at_s] = Time.new.to_i if options[:created_at_s].nil?
    options[:updated_at_s] = Time.new.to_i if options[:updated_at_s].nil?
  end

  # class methods here
  def self.t(local_key, options = {})
    key = self.name.underscore
    key = "models.#{key}.#{local_key}"
    translate key, options
  end

  def self.h(text)
    ERB::Util.h(text)
  end

  def self.ohm_paginate(collection, page, per_page, total = nil)
    @collection = WillPaginate::Collection.create(page, per_page, total) do |pager|
      pager.replace collection[pager.offset, pager.per_page]
    end
    @collection
  end

  class << self
    include Helpers::TranslateHelper
  end
  
end

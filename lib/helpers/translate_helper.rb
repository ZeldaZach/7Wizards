module Helpers::TranslateHelper

  def d(date, format = :short)
    return nil if date.nil?
    format = "%d %b %H:%M:%S" if format == :medium
    date = Time.parse(date) if date.is_a? String
    date = date.getlocal if date
    I18n.l date, :format => format
  end

  # translation
  def translate(key, options = {})
    I18n.t(key, options)
  end

  def tg(key, options = {})
    I18n.t(key, options)
  end

  def tf(model, field, default = nil)
    clazz = model.is_a?(Class) ? model : model.class
    key = "#{clazz.name.underscore}.#{field}"
    I18n.t(key, {:scope => [:activerecord, :attributes], :default => default})
  end

  def te(field, default = nil)
    I18n.t(field, {:scope => [:activerecord, :errors, :messages], :default => default})
  end

  def tr(key, options = {})
    key = "rules.#{self.name.underscore}.#{key}"
    translate(key, options)
  end

  # translate price
  def tp(price)
    tg :money, :count => price
  end

  # translate price staff
  def tps(price_staff)
    tg :staff, :count => price_staff
  end

  # translate price staff2
  def tps2(price_staff2)
    tg :staff2, :count => price_staff2
  end

end

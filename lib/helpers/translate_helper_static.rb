module Helpers::TranslateHelperStatic
  def self.included(klass)
    klass.extend ClassMethods
  end

  module ClassMethods
    include Helpers::TranslateHelper
  end
end

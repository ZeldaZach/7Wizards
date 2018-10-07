module ActionView
  module Helpers
    module PrototypeHelper
      class JavaScriptGenerator
        module GeneratorMethods
          def call_fn(function)
            record function
          end

          def redirect_to(location)
            url = location.is_a?(String) ? location : @context.url_for(location)
            record "navigate(#{url.inspect})"
          end
        end
      end
    end
  end
end
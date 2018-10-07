module Helpers
  module FormattingHelper
    def np(number)
      number = number.to_i if number.is_a?(String)
      number > 0 ? "+" + number.to_s : number.to_s
    end
  end
end
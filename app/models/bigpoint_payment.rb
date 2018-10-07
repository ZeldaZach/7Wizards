class BigpointPayment < ActiveRecord::Base

  def self.log(params)
    converted_params = {}
    # Convert each attribute from CamelCase notation to under_score notation
    # For example, merchantReference will be converted to merchant_reference
    params.each do |key, value|
      key = "payment_type" if key == :type #FIX

      field_name                   = key.to_s.underscore
      if self.column_names.include?(field_name)
        converted_params[field_name] = value
      end
    end
    self.create!(converted_params)
  end

end

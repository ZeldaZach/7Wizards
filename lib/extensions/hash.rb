class Hash
  def self.to_url_params(hash)
    elements = []
    hash.each do |key, value|
      if key && value && !key.is_a?(Hash) && !value.is_a?(Hash)
        elements << "#{CGI::escape(key)}=#{CGI::escape(value)}" if !["controller", "action"].include?(key)
      end
    end

    url = elements.join('&')
    url = "?" + url if elements.length > 0
    url
  end

  def self.to_ajax_name(hash)
    elements = ""
    hash.each do |key, value|
      if !key.is_a?(Hash) && !value.is_a?(Hash)
        elements << "#{key}_#{value}" if !["controller", "action", "_method"].include?(key)
      end
    end
    return elements
  end

  def self.from_url_params(url_params)
    result = {}.with_indifferent_access
    url_params.split('&').each do |element|
      element = element.split('=')
      result[element[0]] = element[1]
    end
    result
  end
end

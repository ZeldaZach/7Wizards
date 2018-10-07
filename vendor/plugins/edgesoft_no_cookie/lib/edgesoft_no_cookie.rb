# EdgesoftNoCookie
# Version: 1.1
# Rails version: 1.x
# Author: Long On
# Bugs: long.on@edgesoft.ca
#
# (c) Copyright 2006-2008 Edgesoft Consulting Inc.
#
module EdgesoftNoCookie
  # Inject session key in URL if session_enabled? and can not detect browser cookie
  def url_for(options = {}, *parameters_for_method_reference)
    if request.session_options && request.session_options[:disabled] != false then
      hash = ActionController::Base.session_options || {}
      key_name = hash[:session_key].blank? ? '_session_id' : hash[:session_key]

      if request.cookies.has_key?(key_name) then
        return super
      end

      options = set_url_param options, key_name, request.session_options[:id]
    end
    super
  end

  def set_url_param(options, param, value)
    if options.class == String
      v = "#{param.to_s}=#{value.to_s}"
      if m = options.match(/#{param}=(\w*)/)
        options = options.gsub(m[0], v)
      else
        options += options.include?('?') ? '&' : '?'
        options += v
      end
    else
      options.update( param => value )
    end
  end
  
end


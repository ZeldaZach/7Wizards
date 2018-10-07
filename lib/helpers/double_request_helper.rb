module Helpers
  module DoubleRequestHelper

    def confirm_drid(redirect_options = nil)

      r = false
      
      drid = params[:drid]
      unless drid.blank?
        u = current_user
        if u
          key = "dr_id_#{u.id}"
          rid = RedisInstance.redis.getset(key, nil)
          r = drid.to_i == rid.to_i
        end
      end

      if !r && redirect_options
        redirect_to_with_notice tg(:drid_is_not_confirmed), redirect_options
      end
      
      r
    end

    def drid(options)
      o = options.dup
      o[:drid] = double_request_id
      o
    end

    # double request id always owerrides previous request id
    def double_request_id
      r = @double_request_id
      unless r
        u = current_user
        if u
          key = "dr_id_#{u.id}"
          r = rand(10000)
          RedisInstance.redis.set key, r
          @double_request_id = r
        end
      end
      r
    end
    
  end

end

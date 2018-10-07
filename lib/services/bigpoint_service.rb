module Services::BigpointService

  class Game
    ACTIONS = {
      :register  => "game.registerAndLogin",
      :login     => "game.login",
      :delete    => "game.deleteUser",
      :stats     => "game.getUserStats",
      :book_item => "bookItem",
      :block     => "blockedNotify",
      :get_lang  => "getUserPaymentLanguage"
    }
    def initialize(request)
      @data    = request.env["RAW_POST_DATA"]
      @request = request
      parse(@request.params)
    end

    def method_name
      @method
    end

    def auth
      @auth
    end

    def params
      @params
    end

    def params_array
      @array
    end

    def get_user_and_adjust
      if check
        case self.method_name
        when ACTIONS[:register]
          return self.register
        when ACTIONS[:login]
          return self.get_user
        when ACTIONS[:delete]
          return self.delete
        when ACTIONS[:stats]
          return self.get_user
        when ACTIONS[:book_item]
          return self.buy_gold
        when ACTIONS[:block]
          if params[:blocked] == 1
            u = self.block
          else
            u = self.unblock
          end
          return u
        when ACTIONS[:get_lang]
          return self.get_user
        end
      end
      nil
    end

    def get_user
      
      conditions = {}
      conditions[:deleted] = false
      conditions[:bp_user_id] = self.params[:bpUserID]
      conditions[:id] = self.params[:userID] unless self.params[:userID].blank?

      User.find :first, :conditions => conditions
    end

    def register
      user = self.get_user
      return user unless user.nil?

      user = User.new
      user.bp_user_id      = self.params[:bpUserID]
      user.bp_affiliate_id = self.params[:affiliateID]
      user.bp_name         = self.params[:username]
      user.bp_user_country = self.params[:userCountry]

      #TEMPORATY DATA
      user.name     = "ACTIVATE#{self.params[:bpUserID]}"
      user.gender   = "m"
      user.email    = "mail#{self.params[:bpUserID]}_#{rand(10)}@7wizards.com"
      user.password = "7wIz#{rand(10000)}"
      user.active_avatar_id = 1 #default avatar
      user.register

      saved = user.save!

      return saved ? user : nil
    end

    def block
      user = User.find_by_id(params[:userID])
      if user
        ban = BanHistory.new({
            :ban => true,
            :only_messages => true,
            :ban_end_date => 120.days.since,
            :public_reason => "You are blocked by Bigpoint"
          })
        user.active = false
        ban.user = user

        ban.transaction do
          ban.save!
          user.save!
        end
      end
      user
    end

    def unblock
      user = User.find_by_id(params[:userID])
      if user
        ban = BanHistory.new({
            :ban => false,
            :only_messages => false
          })
        user.active = true
        ban.user = user

        ban.transaction do
          ban.save!
          user.save!
        end
      end
      user
    end

    def delete
      user = self.get_user
      if user
        user.active = false
        user.deleted = true
        return user if user.save!
      end
      nil
    end

    def buy_gold
      u = User.find_by_id(params[:userID])
      if u

        BigpointPayment.log(params)

        staff = params[:amount]
        u.add_staff!(staff, "buy_gold", "bigpoint.buy_gold", PaymentLog::BUY_STAFF, GameProperties::BIGPOINT_PRODUCTS["#{staff}"])
        Message.send_buy_gold_processed(u, staff)
        return u
      end
      nil
    end

    private

    def check
      return Digest::MD5.hexdigest("#{@data}#{BigpointConfig.security_code}") == self.auth
    end

    def parse(options)
      begin
        @auth   = options[:authHash]
        @method = options[:methodCall][:methodName]
        p = options[:methodCall][:params][:param][:value][:struct][:member]
        @params = {}
        @array = []
        p.each do |item|
          @params[item[:name].to_sym] = to_type(item[:value])
          @array << to_type(item[:value])
        end
      rescue
      end
    end

    def to_type(value)
      case value.keys.first.downcase
      when "int"
        r = value.values.first.to_i
      when "i4"
        r = value.values.first.to_i
      when "double"
        r = value.values.first.to_f
      else
        r = value.values.first.to_s
      end
      r
    end
  end

  class IFrame
    
    REGISTER_URL = "http://portal-api.bigpoint.net/unified-signup/"
    LOGIN_URL    = "http://portal-api.bigpoint.net/unified-login/"
    
    def get_login_frame
      "#{LOGIN_URL}?#{get_variables}"
    end

    def get_register_frame
      "#{REGISTER_URL}?#{get_variables}"
    end

    def get_variables
      lang = "en"
      time = Time.now.to_i
      
      params = BigpointConfig.partner_id.to_s
      params << BigpointConfig.project_id.to_s
      params << lang
      params << CGI::escape("#{BigpointConfig.host}/stylesheets/bigpoint.css").downcase
      params << time.to_s
      params << BigpointConfig.security_code

      hash = Digest::MD5.hexdigest(params)
      options = {}
      options[:partnerID]    = BigpointConfig.partner_id
      options[:projectID]    = BigpointConfig.project_id
      options[:lang]         = lang
      options[:cssurl]       = "#{BigpointConfig.host}/stylesheets/bigpoint.css"
      options[:authTimestamp]= time
      options[:hash]         = hash

      vars = options.map { |k, v| URI.escape("%s=%s" % [k, v]) }.join('&')
      vars
    end
    
  end

  class Payment

    def self.buy_url(user, time)
      req = {
        :projectID => BigpointConfig.project_id,
        :lang      => "en",
        :username  => user.bp_name,
        :userID    => user.id,
        :time      => time.to_i,
        :returnURL => BigpointConfig.host
      }

      req[:sandbox] = 1 if ENV['RAILS_ENV'] != 'production'
      
      req_json  = Base64.encode64(req.to_json).gsub("\n", "")
      hash_json = Digest::MD5.hexdigest("#{req_json}#{BigpointConfig.security_code}")
      "#{BigpointConfig.payment_url}?authreq=#{CGI::escape(req_json)}&hash=#{CGI::escape(hash_json)}"
    end
    
  end
end

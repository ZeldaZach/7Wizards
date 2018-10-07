module ClanExt
  module Payment

    def spend_staff2(price, key, description = nil)
      self.a_staff2 -= price
      self.payment_log "SPEND STAFF2", price, key, description
    end

    def spend_staff2!(price, key, description = nil)
      self.spend_staff2 price, key, description
      self.save!
    end

    def add_staff2(price, key, description = nil)
      self.a_staff2 += price
      self.payment_log "CLAN ADD STAFF2", price, key, description
    end

    def add_staff2!(price, key, description = nil)
      self.add_staff2 price, key, description
      self.save!
    end
    
    def spend_money(price, key, description = nil)
      self.a_money -= price
      self.payment_log "CLAN SPEND MONEY", price, key, description
    end

    def spend_money!(price, key, description = nil)
      self.spend_money price, key, description
      self.save!
    end

    def add_money(price, key, description = nil)
      self.a_money += price
      self.payment_log "ADD MONEY ", price, key, description
    end

    def add_money!(price, key, description = nil)
      self.add_money price, key, description
      self.save!
    end
    
    def payment_log(action, price, key, description = nil)
      User.payments_logger.info "Time: #{Time.new.strftime("%Y-%m-%d %H:%M")} clan_id:#{self.id} #{action} Price: #{price} Key: #{key}, #{description}"
    end
    
    def self.included(klass)
      klass.extend ClassMethods
    end

    module ClassMethods

      def payments_logger()
        return @@logger if @@logger

        logfile = File.open(RAILS_ROOT + '/log/payments.log', 'a')    #create log file
        logfile.sync = true                                           #automatically flushes data to file
        @@logger = Logger.new(logfile)                                #constant accessible anywhere
      end

      @@logger = nil
    end

  end
end

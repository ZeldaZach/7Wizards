module UserExt
  module Payment

    # nil if we have no limit for user
    def get_max_level_money
      max_money = nil
      if GameProperties::GAME_MONEY_LIMIT_LEVELS.include? self.a_level
        max_money = self.a_level * GameProperties::GAME_MONEY_LIMIT_COEFICIENT
      end
      max_money
    end

    def reach_max?
      m = get_max_level_money
      m ? self.a_money >= m : false
    end
    
    def spend_staff(price, key, description)
      self.a_staff -= price
      PaymentLog.spend_staff(self, price, key, description)
    end

    def spend_staff!(price, key, description)
      self.spend_staff(price, key, description)
      self.save!
    end

    def add_staff(amount, key, description, kind = PaymentLog::ADD_BONUS, price_value = nil)
      self.a_staff += amount.to_i
      PaymentLog.add_staff(self, amount, key, description, kind, price_value)
    end

    def add_staff!(amount, key, description, kind = PaymentLog::ADD_BONUS, price_value = nil)
      self.add_staff(amount, key, description, kind, price_value)
      self.save!
    end

    def spend_staff2(price, key, description = "")
      self.a_staff2 -= price
      self.payment_log "SPEND STAFF2", price, key, description
    end

    def spend_staff2!(price, key, description = "")
      self.spend_staff2 price, key, description
      self.save!
    end

    def add_staff2(price, key, description = "")
      self.a_staff2 += price
      self.payment_log "ADD STAFF2", price, key, description
    end

    def add_staff2!(price, key, description = "")
      self.add_staff2 price, key, description
      self.save!
    end
    
    def spend_money(price, key, description = "")
      self.a_money -= price
      self.payment_log "SPEND MONEY", price, key, "#{description} LEFT MONEY: #{self.a_money}"
    end

    def spend_money!(price, key, description = "")
      self.spend_money price, key, description
      self.save!
    end

    def add_money(price, key, description = "")
      max_money = get_max_level_money
      price = [(max_money - self.a_money), 0].max if max_money && self.a_money + price > max_money

      if price > 0
        description += " BEFORE MONEY #{self.a_money}"
        self.a_money += price
        self.payment_log "ADD MONEY ", price, key, description
      end
      
      if reach_max? && (self.e_sent_max_money.nil? || self.e_sent_max_money > 1.days.since)
        self.e_sent_max_money = Time.now
        Message.store_max_mana(self)
      end
    end

    def add_money!(price, key, description = "")
      self.add_money price, key, description
      self.save!
    end
    
    def payment_log(action, price, key, description = nil)
      User.payments_logger.info "Time: #{Time.new.strftime("%Y-%m-%d %H:%M")} user_id:#{self.id} #{action} Price: #{price} Key: #{key}, #{description}"
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

module UserExt
  module Adjust

    def self.included(klass)
      klass.extend ClassMethods
    end

    module ClassMethods
      # class methods here

      def find_and_adjust(id)
        user = find_by_id id
        if user && user.active
          user.adjust_attributes
          return user
        end
        
        nil
      end
    end

    def adjust_attributes!(by_user = false)
      adjust_attributes by_user, true
    end

    # this method can be called by user personally or by another user before fight for example
    def adjust_attributes(by_user = false, process_save = true)
      RedisLock.lock("user_#{self.id}_adjust") do
        save_record = false

        active_was_changed = false
        if !self.active_messaging
          if by_user
            
            ban = self.last_ban
            if ban && BanHistory.activate(self, {:only_messages => true, :check_end_date => true})
              active_was_changed = true
              save_record = true
            end
          end
        end

        returned_from_holiday = by_user && self.on_holiday?
        if !self.active && !active_was_changed && self.adjust_time
          active_was_changed = BanHistory.active_changed_since(self, self.adjust_time)
        end

        # if user returned from holiday or active state was changed since last adjustment
        # we should reset plantation and health counters
        if returned_from_holiday || active_was_changed
          GamePlantationItem.reset self
          GameHealthRegenerationItem.reset self
          save_record = true
        end

        if returned_from_holiday
          self.register_activity('returned from holiday')
        end

        # adding user money if during partol user found something
        if self.meditation_started_at && self.meditation_finished_at && self.meditation_finished_at < Time.now
          self.a_experience += self.meditation_experience if self.meditation_experience
          
          minutes = ((self.meditation_finished_at - self.meditation_started_at)/60).to_i
          self.s_meditation_minutes += minutes

          # options for event
          event_options = {}
          
          # if user has meditation curse we should use it
          if UserItems::ShopCursePatrol.fired?(self)
            self.meditation_money = 0
            event_options[:meditation_curse] = true
          else
            # if user has meditation gift then we should use it
            UserItems::ShopGiftPatrol.apply_money(self)

            stahanka = UserItems::AmuletStahanka.get_percent(self)
            self.meditation_money = (self.meditation_money.to_f * (1 + stahanka)).to_i

            if rand < GameProperties::MEDITATION_NIRVANA_PROBABILITY
              event_options[:meditation_nirvana] = true
              self.meditation_money *= 2
            end

            self.add_money(self.meditation_money, "meditation", "Meditating minutes: #{minutes}") if self.meditation_money > 0
          end

          Message.create_meditation(self, event_options)

          self.meditation_money = nil
          self.meditation_experience = nil
          self.meditation_started_at = nil
          self.meditation_finished_at = nil

          AllGameItems::ACHIVEMENT_MEDITATION.extend(self, minutes.to_i)
          
          save_record = true
        end

        # adjust level depends on experience
        if self.a_experience >= self.next_level_experience
          self.a_level += 1

          if self.a_level == GameProperties::REFERENCE_BONUS_LEVEL && self.referral

            if self.referral.s_referral_bonus_count < GameProperties::REFERENCE_BONUS_COUNT
              self.referral.add_staff GameProperties::REFERENCE_BONUS_STAFF,
                "referral_bonus",
                "referral bonus for reference: #{self.id} created at: #{self.created_at}"
              self.referral.s_referral_bonus_count += 1
              self.referral.save!

              Message.send_reference_bonus_level self.referral, self, GameProperties::REFERENCE_BONUS_STAFF
            end
          end

          save_record = true
          Message.new_level(self, self.a_level)
        end

        if !self.on_holiday?
          # adjust plantation related attributes
          if GamePlantationItem.adjust? self
            save_record = true
          end

          # adjust health regeneration
          if GameHealthRegenerationItem.adjust? self
            save_record = true
          end
        end

        # adjust fight count
        if GameEnduranceItem.adjust?(self)
          save_record = true
        end

        # activate messaging
        if by_user && !self.active_messaging
          if BanHistory.activate self,
              :check_end_date => true,
              :only_messages => true,
              :private_reason => "auto: time activation of messaging"
            save_record = true
          end
        end 

        #        # user has limitation of money he can change per day by this code we are reseting limitation
        #        if self.last_money_change_time && !self.last_money_change_time.today? && self.changed_money_today != 0
        #          self.changed_money_today = 0
        #          save_record = true
        #        end

        if save_record
          self.adjust_time = Time.now
          self.register_activity('adjust by user') if by_user
          if process_save
            save!
          end
        end

        return true
      end
    end
    false
  end
end

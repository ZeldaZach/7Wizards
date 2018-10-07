# refactored but not used ...

module UserExt
  module Pet

    def has_pet?
      !self.pet_kind.nil?
    end

    def pet_is_dead?
       has_pet? && self.pet_health < 1
    end

    def pet_is_live?
      has_pet? && !pet_is_dead?
    end

    def pet_active?
      has_pet? && self.pet_active == true && !pet_is_dead?
    end

    def max_pet_health
      max = HealthGrowthTable.get_max_health(self, true)
      (max.to_f / 10).ceil
    end

    def pet_health_hour_regeneration
      r = HealthGrowthTable.get_hour_regeneration(self, true)
      (r.to_f / 10).ceil
    end

    def increase_pet_health(increment)
      if pet_is_live?
        self.pet_health = self.pet_health + increment
      end
    end

    def pet_health=(value)
      value = [value, 0].max
      value = [value, max_pet_health].min
      self[:pet_health] = value
    end

    PET_1 = 1
    PET_2 = 2
    PET_3 = 3

    def pet_kill_skill_bonus
      GameProperties::KILL_PET_SKILL_BONUS.call self.pet_skill, self.s_kill_pets
    end

    def self.included(klass)
      klass.extend ClassMethods
    end

    module ClassMethods

      def pet_kinds
        [PET_1, PET_2, PET_3]
      end

    end

  end
end

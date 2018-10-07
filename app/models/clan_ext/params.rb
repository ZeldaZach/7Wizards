module ClanExt
  module Params

    def clan_id
      id
    end

    def clan_name
      name
    end

    def user_count
      self.users.count
    end

    def places_count
      AllClanItems::PLACES.get_places(self)
    end

    def free_places
      [0, self.places_count - self.user_count].max
    end

    def a_money
      m = self[:a_money]
      m && m > 0 ? m : 0
    end

    def a_money=(value)
      self[:a_money] = [value, 0].max
    end

    def a_staff2
      m = self[:a_staff2]
      m && m > 0 ? m : 0
    end

    def a_staff2=(value)
      self[:a_staff2] = [value, 0].max
    end

    def rating
      if !defined?(@rating) || !@rating
        @rating = calculate_rating
      end
      @rating
    end

    def rating=(value)
      @rating = value
    end

  end
end

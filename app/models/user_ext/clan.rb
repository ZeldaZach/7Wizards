module UserExt
  module Clan

    def is_clan_owner(clan)
      !clan.nil? && self.clan == clan && clan.owner == self
    end

    def is_clan_creator(clan)
      !clan.nil? && self.clan == clan && clan.creator == self
    end

    def is_clan_owner?
      is_clan_owner(self.clan)
    end

    def is_clan_creator?
      is_clan_creator(self.clan)
    end

    def in_clan?(clan)
      clan && self.clan == clan
    end

    def clan_name
      clan ? clan.name : ''
    end

  end
end

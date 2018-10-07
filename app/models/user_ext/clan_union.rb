module UserExt
  module ClanUnion
    def on_union_war?(user)
      false
#      return false if !self.clan || !user.on_war? || !user.current_war.started?
#      clan = user.current_war.get_opponent_clan(user.clan)
#      self.clan.has_union?(clan)
    end
  end
end

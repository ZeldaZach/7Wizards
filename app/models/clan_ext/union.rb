module ClanExt
  module Union
    def unions
#      ClanUnion.unions(self)
      []
    end

    def union_clans
#      ClanUnion.union_clans(self)
      []
    end

    def pending_unions
#      ClanUnion.pending_unions(self)
      []
    end

    def has_union?(clan)
#      ClanUnion.has_union? self, clan
      false
    end

    def has_pending_union?(clan)
#      ClanUnion.has_pending_union? self, clan
      false
    end

    def has_active_or_pending_union?(clan)
#      ClanUnion.has_active_or_pending_union? self, clan
      false
    end

    def current_month_unions_count
#      ClanUnion.current_month_unions_count self
      0
    end
  end
end

module UserExt
  module Relations
    def has_relation?(user, kind)
      Relation.has_relation? self, user, kind
    end

    def has_relation_active?(user, kind)
      Relation.has_active_relation? self, user, kind
    end

    def is_friend?(user)
      has_relation? user, Relation::KIND_FRIEND
    end

    def is_active_friend?(user)
      has_relation_active? user, Relation::KIND_FRIEND
    end

    def is_bookmark_list?(user)
      has_relation? user, Relation::KIND_BOOKMARK
    end

    def in_enemy_list?(user)
      has_relation? user, Relation::KIND_VENGENCE
    end

    def in_rob_list?(user)
      has_relation? user, Relation::KIND_ROB
    end

    def is_ignore_list?(user)
      has_relation? user, Relation::KIND_IGNORE
    end
  end
end

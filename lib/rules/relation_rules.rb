class RelationRules < AbstractRules

  def self.can_create_relation(user, relation)
    r = Rule.new

    if !user.confirmed_email
      r.message = tg(:account_not_activated)
      return r
    end
    
    if relation.user == relation.relative
      r.message = t(:cant_add_yourself)
      return r
    end

    if Relation::KIND_FRIEND == relation.kind &&
        Relation.count_relation(user, relation.relative, Relation::KIND_FRIEND) > 0
      r.message = t :already_send_friend_request_on_create, :name => relation.relative.name
      return r
    end

    r
  end

  def self.can_accept_relation(user, relation)
    r = Rule.new

    if !user.confirmed_email
      r.message = tg(:account_not_activated)
      return r
    end
    
    if relation.nil? || relation.active || !relation.is_friend?
      r.message = tg(:strange_situation)
      return r
    end

    #TODO 
    relations = Relation.all :conditions => { :user_id => relation.user_id, :relative_id => relation.relative_id,
      :kind => Relation::KIND_FRIEND, :active => true }
    unless relations.blank?
      relations = relations.first
      key = "already_have_relation_on_accept_#{relations.kind}"
      r.message = t key, :name => relation.relative.name
      return r
    end
    
    r
  end

  def self.can_send_present(user, relative, present)
    r = Rule.new
    
    if !user || !relative || !present || user == relative
      r.message = t(:strange_situation)
      return r
    end
    
    if present.is_a? UserItems::ShopGift
      unless user.is_active_friend?(relative)
        r.message = t(:sent_gift_to_non_friend)
        return r
      end

      if UserItems::ShopCurseAntiGift.active?(relative)
        r.message = t(:sent_gift_to_anti_gift_curse, :name => relative.name)
        return r
      end
    end

    if present.is_a? UserItems::ShopCurse
      if user.is_active_friend?(relative)
        r.message = t(:sent_curse_to_friend)
        return r
      end
    end

    category = present.category

    sent_today = UserItem.count :conditions => ["bought_by_id = ? and reasigned_at > ? and user_id in (?) and category = ?",
      user, Time.now.beginning_of_day, [relative.id, -relative.id], category]
    if sent_today >= GameProperties::PRESENT_SENT_DAY_LIMIT_TO_USER
      r.message = t("sent_day_limit_user_#{category}", :name => relative.name, :max => GameProperties::PRESENT_SENT_DAY_LIMIT_TO_USER)
      return r
    end

    max_per_day = GameProperties::PRESENT_SENT_DAY_LIMIT_TO_ALL.call(user)
    sent_today = UserItem.count :conditions => ["bought_by_id = ? and reasigned_at > ? and category = ?",
      user, Time.now.beginning_of_day, category]
    if sent_today >= max_per_day
      r.message = t("sent_day_limit_all_#{category}", :max => max_per_day)
      return r
    end

    received_today = UserItem.count :conditions => ["user_id in (?) and reasigned_at > ? and category = ?",
      [relative.id, -relative.id], Time.now.beginning_of_day, category]
    if received_today >= GameProperties::PRESENT_MAX_RECEIVE_PER_DAY
      r.message = t("received_day_limit_#{category}", :name => relative.name, :max => GameProperties::PRESENT_MAX_RECEIVE_PER_DAY)
      return r
    end

    r
  end

  def self.can_cancel_curse(user, potion, options = {})
    r = Rule.new

    if !potion || !user.has_item?(potion.key)
      r.message = t(options[:curse] ?
          :cancel_curse_potion_not_exists :
          :cancel_all_curses_potion_not_exists)
      return r
    end

    ProfileRules.can_use_item(user, potion, options)
  end

  def self.can_block_user(user, relative)
    r = Rule.new

    if relative.nil? || user.nil?
      r.message = t(:strange_situation)
      return r
    end

    if user.is_ignore_list?(relative)
      r.message = t(:already_blocked)
      return r
    end
    r
  end

  def self.can_unblock_user(user, relative)
    r = Rule.new
    
    if relative.nil? || user.nil?
      r.message = t(:strange_situation)
      return r
    end

    if !user.is_ignore_list?(relative)
      r.message = t(:is_not_blocked)
      return r
    end

    r
  end

end

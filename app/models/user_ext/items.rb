module UserExt
  module Items

    def has_item?(item)
      item_key = item.is_a?(String) ? item : item.key
      !get_item_by_key(item_key).nil?
    end

    def uses_item?(item)
      item_key = item.is_a?(String) ? item : item.key
      i = get_item_by_key(item_key)
      i && i.in_use
    end

    def get_item_by_key(item_key)
      items.each do |user_item|
        if user_item.key == item_key
          return user_item
        end
      end
      nil
    end

    def get_items_count_by_key(item_key)
      r = 0
      items.each do |user_item|
        if user_item.key == item_key
          r += 1
        end
      end
      r
    end

    def available_items(options = {})
      items.select do |i|
        r = !i.in_use
        r &&= i.is_include_a?(options[:class]) if options[:class]
        r &&= i.for_pet? if options[:pet]
        r
      end
    end

    def used_items(options = {})
      items.select do |i|
        r = i.in_use
        r &&= i.active_till > Time.new if i.active_till
        r &&= i.is_include_a?(options[:class]) if options[:class]
        r &&= i.for_pet? if options[:pet]
        r
      end
    end

    def available_clothes_items
      available_items :class => [UserItems::ShopCloses, UserItems::ShopPotion]
    end
    
    def used_clothes_items
      used_items :class => UserItems::ShopCloses
    end

    def available_amulets
      available_items :class => UserItems::Amulet
    end

    def available_pet_amulets
      available_items :class => UserItems::Amulet, :pet => true
    end

    def used_amulets
      used_items :class => UserItems::Amulet
    end

    def used_pet_amulets
      used_items :class => UserItems::Amulet, :pet => true
    end

    def available_pet_items
      available_items :pet => true, :class => UserItems::ShopPotion
    end

    def used_pet_items
      used_items :pet => true#TODO
    end

    def available_gifts
      available_items :class => UserItems::ShopGift
    end

    def used_gifts
      used_items :class => UserItems::ShopGift
    end

    def available_curses
      available_items :class => UserItems::ShopCurse
    end

    def used_curses
      used_items :class => UserItems::ShopCurse
    end

    def sent_gifts_count(friend)
      reasigned_items.sent_gifts_to_user(friend).size
    end

  end
end

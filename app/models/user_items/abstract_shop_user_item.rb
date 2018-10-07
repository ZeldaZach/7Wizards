class UserItems::AbstractShopUserItem < UserItems::AbstractLevelUserItem

  def for_pet?
    self.class.for_pet?
  end

  class << self

    def for_pet?
      @config_pet == true
    end

    def can_use?(user, options = {})
      r = super(user, options)
      return r if !r.allow?

      item = get_used_from_category(user)
      unless item.nil?
        r.message = tr(:already_use_item_from_category,
          {
            :category => self.category_label,
            :item => item.title
          }
        )
        return r
      end
      r
    end

    def get_used_from_category(user)
      user.used_clothes_items.each do |item|
        if item.category == self.category
          return item
        end
      end
      nil
    end

  end

end
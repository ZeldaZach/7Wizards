class AllUserItems

  class << self

    def reset
      @@inventory = {}
      @@all_items = {}

      r UserItems::ShopPotion::CATEGORY, UserItems::ShopPotion
      r UserItems::ShopCloses::HELMET_CATEGORY, UserItems::ShopCloses
      r UserItems::ShopCloses::WEAPON_CATEGORY, UserItems::ShopCloses
      r UserItems::ShopCloses::ARMOUR_CATEGORY, UserItems::ShopCloses
      r UserItems::ShopCloses::SHIELD_CATEGORY, UserItems::ShopCloses
      r UserItems::ShopCurse::CATEGORY, UserItems::ShopCurse
      r UserItems::ShopGift::CATEGORY, UserItems::ShopGift
      r UserItems::Amulet::CATEGORY

      # TODO should be removed in future ...
      ro UserItems::ShopCurseCurseC01, "ShopCursesCursesC01"
      ro UserItems::ShopCurseCurseC02, "ShopCursesCursesC02"
      ro UserItems::ShopCurseCurseC03, "ShopCursesCursesC03"
      ro UserItems::ShopCurseCurseC04, "ShopCursesCursesC04"

      nil
    end

    def categories
      [ UserItems::ShopCloses::WEAPON_CATEGORY,
        UserItems::ShopCloses::ARMOUR_CATEGORY,
        UserItems::ShopCloses::HELMET_CATEGORY,
        UserItems::ShopCloses::SHIELD_CATEGORY,
        UserItems::ShopPotion::CATEGORY,
        UserItems::ShopGift::CATEGORY,
        UserItems::ShopCurse::CATEGORY,
        UserItems::Amulet::CATEGORY ]
    end

    def default_category
      UserItems::ShopCloses::WEAPON_CATEGORY
    end

    def get_category_keys(category)
      r = @@inventory[category.to_sym]
      p category
      r.collect do |item|
        item.key
      end
    end

    def find_by_key(key)
      @@all_items[key]
    end

    def find_by_category(category)
      r = @@inventory[category.to_sym]
      r ? r : []
    end

    def find_by_category_and_level(category, level)
      r = find_by_category category
      res = r.select do |i|
        i.required_level <= level + 5
      end
      if res.length < 3
        res = r[0..2]
      end

      res = res.sort do |i1, i2|
        i1.required_level <=> i2.required_level
      end

      res
    end

    def find_by_keys(array)
      r = []
      return r if array.nil?
      
      array.each do |key|
        r <<  find_by_key(key)
      end
      r
    end

    private

    # registration method
    def r(category, item_clazz = nil, ss = '')
      items = []

      f = File.join(Rails.root, "config", "game", "user_items", "#{category}.yml")
      o = YAML.load_file(f)
      o.each_pair do |key, value|

        if value["class"]
          clazz = value["class"]
          item_class = UserItems.const_get(clazz)
        else
          clazz = item_clazz
          class_name = "#{clazz}#{ss}#{category.to_s.camelize}#{ss}#{key.camelize}"

          item_class = eval <<-CLASS
            class #{class_name} < #{clazz}
            end
            #{class_name}
          CLASS
        end

        value['key'] = key
        value['category'] = category.to_s
        
        value.each_pair do |config_key, config_value|
          item_class.instance_variable_set "@config_#{config_key}", config_value
          item_class.class_eval <<-METHOD
            def self.config_#{config_key}
              instance_variable_get "@config_#{config_key}"
            end
          METHOD
        end

        items << item_class
        @@all_items[key] = item_class
      end

      items.sort! do |item1,item2|
        k1 = item1.key[1..item1.key.length - 1]
        k2 = item2.key[1..item2.key.length - 1]
        k1.to_i <=> k2.to_i
      end

      @@inventory[category.to_sym] = items
    end

    # register old classes what we already removed
    # but need to have them just to support deserialization of old data
    def ro(newClass, oldClassName)
      class_name = "UserItems::#{oldClassName}"

      item_class = eval <<-CLASS
        class #{class_name} < #{newClass}
        end
        #{class_name}
      CLASS

      item_class
    end

  end

  private

  @@inventory = nil
  @@all_items = nil

end

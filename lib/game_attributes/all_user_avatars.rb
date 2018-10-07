class AllUserAvatars

  DEFAULT_CLOTHES_KEYS = ["face", "hair", "boots", "top", "middle", "pants"]

  class << self

    def reset
      @@all_avatars = {}
      @@all_avatars_map = {}
      r "m" #Male
      r "f" #Female
      r "d" #Dragon
    end

    def avatars(user)
      r(user.gender)
    end

    def get_by_key(key)
      @@all_avatars_map[key]
    end

    def get_unused(user)
      used_avatars   = user.user_avatars
      unused_avatars = []
      avatars(user).each do |ava|

        used = false
        used_avatars.each do |item|
          used = item.key == ava.key
          break if used
        end
        unused_avatars << ava if !used && default_avatar_key(user) != ava.key
      end
      unused_avatars
    end

    def get_default_avatar(user)
      get_by_key(default_avatar_key(user))
    end

    protected


    def default_avatar_key(user)
      user.gender == "m" ? "male1" : "female1"
    end
    
    def define_instance_method(instance, name, value)
      instance.instance_variable_set "@#{name}", value
      instance.class_eval <<-METHOD
            def self.#{name}
              instance_variable_get "@#{name}"
            end
            def self.#{name}=(value)
              instance_variable_set "@#{name}", value
            end
      METHOD
      instance
    end

    # registration method
    def r(gender)
      return @@avatars[gender] if @@avatars && @@avatars[gender]

      @@avatars ||= {}
      @@avatars[gender] ||= []

      @@all_avatars_map ||= {}

      f = File.join(Rails.root, "config", "game", "avatars", "avatars_#{gender}.yml")
      o = YAML.load_file(f)[RAILS_ENV]
      o.each_pair do |key, value|

        class_name = "UserAvatars::#{key.camelize}"
        
        item_class = eval <<-CLASS
            class #{class_name} < UserAvatar
            end
            #{class_name}
        CLASS
        value['key'] = key
        
        value.each_pair do |config_key, config_value|
          define_instance_method(item_class, "config_#{config_key}", config_value)
        end
        
        default = {}
        #populate default used clothes
        item_class.config_clothes.each do |item_key, item_value|
          if DEFAULT_CLOTHES_KEYS.include?(item_key)
            default[item_key] = {:id => 1, :color => item_value["color"]}
          end
        end
        
        define_instance_method(item_class, "default_used_clothes", default)
        
        @@avatars[gender] << item_class
        @@all_avatars_map[key] = item_class
      end

      @@avatars[gender]
    end

    @@avatars = nil
    @@all_avatars_map = nil
  end
end

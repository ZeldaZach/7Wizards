module UserExt
  module UserAvatars
  
    def unused_avatars
      AllUserAvatars.get_unused(self)
    end

    def has_avatar?(key)
      !get_avatar(key).nil?
    end

    def get_avatar(key)
      self.user_avatars.by_key(key).first
    end

  end
end

class UserAvatarService

  class << self
    
    @@avatar_config = {
      :user_avatar_folder => '/images/avatars/users',
      :user_ext           => "jpg",
      :user_prefix        => "custom"
    }

    def config
      @@avatar_config
    end

    def get_default_image_url(user)
      "/images/skins/user_default_#{user.gender}.jpg"
    end

    def absolute_path(file)
      "public#{file}"
    end

    def get_image_url(user, options = {})
      user_id = user.user_id
      if GameProperties::PROD && !options[:temp] && !options[:local]
#        return Amazon.get_url(user, avatar_name(user_id))
      end

      name = options[:temp] ? avatar_name(user_id,'_tmp') : avatar_name(user_id)
      
      return "#{config[:user_avatar_folder]}/#{name}"
    end

    def avatar_name(id, suffix = '')
      "#{config[:user_prefix]}_#{id}#{suffix}.#{config[:user_ext]}"
    end

    def upload_avatar(user, uploaded_file)
      file_path = absolute_path(get_image_url(user, :temp => true))
      FileUtils.copy(uploaded_file.local_path, file_path)
      FileUtils.chmod 0755, file_path, :verbose => true

      if GameProperties::PROD
#        Amazon.put(avatar_name(user.user_id), file_path, user)
      end
      
    end

    def change_avatar!(user)
      tmp_file_name = absolute_path(get_image_url(user, :temp => true))
      file_name = absolute_path(get_image_url(user, :local => true))

      if File.exist?(tmp_file_name)
        FileUtils.move(tmp_file_name, file_name)
        user.avatar = config[:user_prefix ]
        user.save!
      end
    end

    def delete_user_avatars(user)
      tmp_file_name = absolute_path(get_image_url(user, :temp => true))
      file_name = absolute_path(get_image_url(user))

      File.delete(tmp_file_name)
      File.delete(file_name)

      if GameProperties::PROD
        Amazon.delete(user)
      end
    end

    def reset_avatar!(user)
      delete_user_avatars(user)
      user.avatar = nil
      user.save!
    end

  end
end

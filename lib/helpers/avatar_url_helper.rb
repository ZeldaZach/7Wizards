module Helpers
  module AvatarUrlHelper

    def user_image_url(user, big = false)
      if user.respond_to?(:dragon?) && user.dragon?
        url = "/images/dragon/dragon_#{user.kind}.jpg"
      else
        if user.avatar.nil?
          url = UserAvatarService.get_default_image_url(user)
        else
          url = UserAvatarService.get_image_url(user)
        end
      end
      url
    end

    def pet_image_url(user_or_kind, big = false, suffix = '')
      if user_or_kind.is_a?(Integer) # it's kind
        big_s = big ? '_big' : ''
        "/images/pet/pet_#{user_or_kind}#{big_s}#{suffix}.jpg"
      else
        # if user_or_kind.pet_avatar == 'custom'
        # CustomAvatarService.get_image_url(user_or_kind, CustomAvatarService::PET, big)
        # else
        if user_or_kind.pet_kind
          pet_image_url(user_or_kind.pet_kind, big, suffix)
        else
          nil
        end
        # end
      end
    end

    def available_clan_images
      ["g1", "g2", "g3", "g4", "g5", "g6", "g7", "g8", "g9", "g10"]
    end

    def clan_image_url(clan_or_avatar, back = false)
      if clan_or_avatar.is_a?(String) # it's avatar

        if clan_or_avatar.match(/\;/)
          ava_arr = clan_or_avatar.split(";")
          ava_arr[0] = available_clan_images[0] if ava_arr[0].blank?
          ava_arr[1] = available_clan_images[0] if ava_arr[1].blank?
        else
          ava_arr = [clan_or_avatar, clan_or_avatar]
        end
        
        clan_or_avatar = back ? "#{ava_arr[1]}_back.jpg" : "#{ava_arr[0]}.png"
        "/images/clan/#{clan_or_avatar}"
      else
        # if clan_or_logo.logo == 'custom'
        # CustomAvatarService.get_image_url(clan_or_logo, CustomAvatarService::CLAN, big)
        # else
        if clan_or_avatar.avatar
          clan_image_url(clan_or_avatar.avatar, back)
        else
          clan_image_url(available_clan_images[0], back)
        end
        # end
      end
    end

    def dragon_image_url(dragon)
      user_image_url dragon
    end
  end
end

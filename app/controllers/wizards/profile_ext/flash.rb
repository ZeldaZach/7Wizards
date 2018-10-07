module Wizards
  module ProfileExt
    module Flash

      #called by flash
      def user_data
        user = current_user

        id = flash_params["id"]
        ava_name  = flash_params["avatar"]
        is_dragon = flash_params["is_dragon"]

        user = User.find_by_id(id) if id

        if is_dragon
          user   = Dragon.current
          avatar = user.avatar
        else
          if ava_name.blank?
            avatar = user.active_avatar
          else
            avatar = user.get_avatar(ava_name)
            avatar = AllUserAvatars.get_by_key(ava_name) if avatar.nil?
          end
        end
        
        if user && !user.virtual? && user.id != current_user.id
          is_friends     = current_user.is_active_friend?(user)
          is_same_clan   = current_user.in_clan?(user.clan)
          is_war         = current_user.on_war_with_user?(user)
          #          is_alliance    = current_user.on_war_with_user?(user.clan)
        end

        
        options = {}
        options[:user_id]     = user.id
        options[:attr_md5]    = user.user_attributes.md5
        options[:success]     = true
        options[:skin]        = avatar.key
        options[:clothes]     = avatar.available_clothes
        options[:used_clothes]= avatar.clothes
        options[:body_color]  = avatar.body_color
        options[:price]       = avatar.price_staff
        options[:level]       = avatar.required_level
        options[:has_avatar]  = user.has_avatar?(avatar.key)
        options[:name]        = user.name
        options[:a_level]     = user.a_level
        options[:pet_kind]    = user.pet_active? ? user.pet_kind : 0
        options[:antipet]     = user.virtual? ? false : AllGameItems::ANTIPET.is_active?(user)
        options[:friends]     = is_friends
        options[:same_clan]   = is_same_clan
        options[:on_war]      = is_war
        options[:on_alliance] = false

        render_json options
      end

      def buy
        user     = current_user
        ava_name = flash_params["avatar"]
        avatar   = AllUserAvatars.get_by_key(ava_name)

        if avatar.nil?
          render_json :success => false, :message => tg(:strange_situation)
          return
        end

        r = avatar.can_buy?(user)
        
        if r.allow?

          user.transaction  do
            avatar.buy! user
            user.save!
          end

          render_json :success => true
        else
          render_json :success => false, :message => r.message
        end
        
      end

      def upload
        UserAvatarService.upload_avatar(current_user, params[:Filedata])
        render :nothing => true
      end

      def clothe_save
        user = current_user
        ava_name   = flash_params["avatar"]
        clothes    = flash_params["clothes"]
        body_color = flash_params["body_color"]

        avatar      = user.get_avatar(ava_name)

        if avatar.nil?
          render_json :success => false, :message => "Has no this avatar" #TODO
          return
        end


        avatar.transaction do
          avatar.clothes    = clothes
          avatar.body_color = body_color
          avatar.save!

          user.active_avatar = avatar
          user.save!
        end

        UserAvatarService.change_avatar!(user)

        user.done_task!(TutorialDressup::NAME)
          
        render_json :success => true
      end
      
    end
  end
end


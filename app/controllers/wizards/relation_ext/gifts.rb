module Wizards
  module RelationExt
    module Gifts

      def gifts
        @relative = User.find params[:id]
        @presents = @user.available_gifts
        @type = UserItems::ShopGift::CATEGORY
        render_popup :title => "Send a gift", :partial => "presents"
      end

      def curses
        @relative = User.find params[:id]
        @presents = @user.available_curses
        @type = UserItems::ShopCurse::CATEGORY
        render_popup :title => "Send a curse", :partial => "presents"
      end

      def send_present
        @type = params[:type]
        @type = UserItems::ShopGift::CATEGORY unless UserItems::ShopCurse::CATEGORY

        return unless confirm_drid :action => @type, :id => params[:id]

        key = params[:present]
        @relative = User.find params[:id]

        RedisLock.lock "present_#{@user.id}" do
          RedisLock.lock "present_#{@relative.id}" do

            @presents = @user.send("available_#{@type}s")
            @present = @presents.select { |gift| gift.key == key}

            if @present.blank?
              redirect_to profile_path(:id => params[:id])
              return
            else
              @present = @present[0]
            end

            r = RelationRules.can_send_present(@user, @relative, @present)
            if r.allow?
              @present.transaction do
                @present.user = @relative

                if @present.need_replacement?
                  replaced_item = @present.find_replacement
                  if replaced_item.nil?
                    
                    redirect_to_with_notice t(:limit_presents_for_send), relation_path(:action => "#{@type}s", :id => params[:id])
                    return
                  else
                    replaced_item.deactivate!
                  end
                end

                @present.reasigned_at = Time.now
                @present.active_till = @present.reasigned_at + @present.hours.hours
                @present.in_use = true
                @present.send_present
                @present.save!

                value = @user.send("s_sent_#{@type}s")
                @user.send("s_sent_#{@type}s=", value + 1)

                value = @relative.send("s_received_#{@type}s")
                @relative.send("s_received_#{@type}s=", value + 1)

                @user.save!
                @relative.save!

                Message.create_sent_present(@relative, @user, @present, @type)

                if @present.is_a? UserItems::ShopGift
                  @user.done_task!(TutorialGifts::NAME)
                  AllGameItems::ACHIVEMENT_GIFTS.gift_extend!(@user, @relative)
                else
                  @user.done_task!(TutorialCurses::NAME)
                end
              end

            else
              redirect_to_with_notice r, relation_path(:action => "#{@type}s", :id => params[:id])
            end
          end
        end

        redirect_to profile_path(:id => @relative)
      end

      def cancel_curse

        RedisLock.lock "present_#{@user.id}" do
          curse = UserItem.find_by_id_and_user_id(params[:id], @user)

          options = {}
          if curse
            options[:curse] = curse
            potion = UserItems::ShopPotionCurse.get_user_potion(@user)
          else
            potion = UserItems::ShopPotionCurseAll.get_user_potion(@user)
          end

          r = RelationRules.can_cancel_curse(@user, potion, options)
          if r.allow?
            potion.transaction do
              potion.use!(@user, options)
            end
          else
            redirect_to_with_notice r, profile_path
          end
        end

        redirect_to profile_path
      end

    end
  end
end
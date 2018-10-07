module Wizards
  module ClanExt
    module War

      def prepare_war
        @clan = owner_clan
        @opponent_clan = Clan.find params[:opponent_clan_id]

        r = ClanRules.can_start_war(@clan, @opponent_clan)
        if r.allow?
          if !@opponent_clan.has_altar?
            @warning_message = t(:opponent_clan_has_not_altar, :name => @opponent_clan.name, :reputation => GameProperties::CLAN_WAR_MINUS_REPUTATION_WITHOUT_ALTAR)
          end
        else
          @error_message = r.message
        end

        render_popup :title => t(:prepare_war_dialog_title)
      end

      def start_war

        @clan = owner_clan
        @opponent_clan = Clan.find params[:opponent_clan_id]

        if !@clan || !@opponent_clan || !confirm_drid
          redirect_to clan_path(:action => 'details')
          return
        end

        war = nil

        RedisLock.lock "start_war_clan_#{@clan.id}" do
          RedisLock.lock "start_war_clan_#{@opponent_clan.id}" do

            @clan.reload
            @opponent_clan.reload

            r = ClanRules.can_start_war(@clan, @opponent_clan)
            if !r.allow?
              redirect_to clan_path(:action => 'details', :id => @clan)
              return
            end

            war = Services::War.start_war @clan, @opponent_clan
          end
        end

        if !war
          redirect_to clan_path(:action => 'details', :id => @clan)
          return
        end

        if !@opponent_clan.has_altar?
          @clan.users.each do |user|
            user.a_reputation = [user.a_reputation - GameProperties::CLAN_WAR_MINUS_REPUTATION_WITHOUT_ALTAR, 0].max
            user.save!
          end
        end

        redirect_to clan_path(:action => 'wars')
      end

      def wars
        @user = current_user
        @clan = @user.clan

        war_id = params[:id]

        @war = ClanWar.find_by_id(war_id) if !war_id.blank?
        @war = @clan.get_last_war_with_rest if @war.nil?
        
        r = ClanRules.can_see_war_history(@clan, @war)
        if !r.allow?
          redirect_to :action => 'details'
          return
        end

        #        # we need this code to support war links in messages
        #        war = ClanWar.find_by_id params[:id]
        #        if war
        #          if last_war != war
        #            redirect_to :action => :union_war, :id => params[:id]
        #          end
        #        end

        if @war

          @order_asc = params[:asc] || false
          @order = params[:order] || 'damage'
          @order_asc = !@order_asc if @order == params[:current_order]

          @clan_users = @war.clan_users @clan, @order + ' ' + (@order_asc ? 'asc' : 'desc')

          @opponent_clan = @war.clan == @clan ? @war.opponent_clan : @war.clan
          @opponent_clan_users = @war.clan_users @opponent_clan, "damage desc"

          @clan_protection = @war.clan_protection(@clan)
          @clan_lost_protection = @war.clan_lost_protection(@clan)
          @clan_damage = @war.clan_damage(@clan)

          @opponent_clan_protection = @war.clan_protection(@opponent_clan)
          @opponent_clan_lost_protection = @war.clan_lost_protection(@opponent_clan)
          @opponent_clan_damage = @war.clan_damage(@opponent_clan)
        end

      end

      def war_strategy
        @user = current_user
        @clan = @user.clan
        if !@clan
          redirect_to :action => 'details'
          return
        end

        @war = @clan.current_war

        if @war
          @formation = params[:f]
          @war_user = @user.current_clan_war_user

          if params[:choose] == 't' && @formation
            if @war_user && !@war_user.formation
              @war_user.formation = @formation
              @war_user.save!
            end
          end

          @users = {}
          clan_war_users = @war.clan_users @clan
          clan_war_users.each do |user|
            if user.user
              if ClanWarUser::FORMATIONS.include? user.formation
                @users[user.formation.to_sym] ||= []
                @users[user.formation.to_sym] << user
              else
                @users[:n] ||= []
                @users[:n] << user
              end
            end
          end
        end
      end

      def war_items
        @user = current_user
        @clan = @user.clan
        if @clan
          @type = params[:type]
          if @type == Inventories::ClanWarItems::TYPE_INVOCATION
            @items = Inventories::ClanWarItems.get_invocations
            if @clan.on_war?
              dragon = Inventories::ClanWarDragonItem.get_dragon @clan
              if dragon
                new_items = []
                added_dragon = false
                @items.each do |item|
                  if item.is_a?(Inventories::ClanWarDragonItem)
                    if !added_dragon
                      added_dragon = true
                      new_items << dragon
                    end
                  else
                    new_items << item
                  end
                end
                @items = new_items
              end
            end
          else
            @type = Inventories::ClanWarItems::TYPE_BUILDING
            @items = Inventories::ClanWarItems.get_buildings
          end
          @clan_owner = @clan.on_war? && @user.is_clan_owner?
        else
          redirect_to :action => :wars
        end
      end

      def war_item_extend
        user = current_user
        return if (clan = get_clan_required(user)).nil?

        performed = set_lock "clan_war_item_extend_#{clan.id}" do
          item = Inventories::ClanWarItems.get_item params[:item]

          if !clan.on_war? || !item
            redirect_to :action => :wars
            return
          end

          r = Rules::Clan.can_extend_war_item(user, clan, item)
          if r.allow?

            clan.transaction do
              p = item.get_full_price(clan)
              p.pay
              item.extend! clan
              clan.save!
            end

            redirect_to :action => :war_items, :type => item.get_item_type
          else
            redirect_to_with_notice r, :action => :war_items, :type => item.get_item_type
          end
        end

        if !performed
          redirect_to_with_notice tg(:wait_locked), :action => 'war_items'
        end
      end

      def war_history
        war_id = params[:id]
        
        @user = current_user
        @clan = @user.clan

        if !war_id.blank?
          redirect_to :action => 'wars', :id => war_id
          return
        end

        r = ClanRules.can_see_war_history(@clan, @war)
        if !r.allow?
          redirect_to :action => 'details'
          return
        end

        @clan_wars = @clan.get_last_wars_history
      end

    end
  end
end
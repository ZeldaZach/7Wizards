class ClanMessage < ActiveRecord::Base

  # include base mode behaviour
  include BaseModel
  include BaseMessageModel
  
  default_scope :order => 'id desc'

  belongs_to :clan
  belongs_to :author, :foreign_key => "author_id", :class_name => "User"

  HISTORY_CREATED = 1
  HISTORY_USER_JOINED = 3
  HISTORY_WAR_STARTED = 4
  HISTORY_WAR_STARTED_OPPONENT = 5
  HISTORY_WAR_FINISHED_WIN = 6
  HISTORY_WAR_FINISHED_LOSE = 7
  HISTORY_USER_KICKED = 8
  HISTORY_USER_LEAVE = 9
  HISTORY_UNION_CREATED = 20
  HISTORY_UNION_KILLED = 21

  DONATE = 2
  MESSAGE = 10
  JOIN_REQUEST = 11

  ALL_MESSAGES = [HISTORY_CREATED, HISTORY_USER_JOINED, HISTORY_USER_KICKED, HISTORY_USER_LEAVE,
    HISTORY_WAR_STARTED, HISTORY_WAR_STARTED_OPPONENT, HISTORY_WAR_FINISHED_WIN, HISTORY_WAR_FINISHED_LOSE,
    HISTORY_UNION_CREATED, HISTORY_UNION_KILLED, MESSAGE]

  def self.unread_history_count(user)
    return 0 if !user.e_clan_history_read_at || !user.clan

    count :conditions => ['clan_id = ? and kind in (?) and created_at > ?', user.clan.id, ALL_MESSAGES, user.e_clan_history_read_at]
  end

  def self.mark_history_as_read!(user)
    user.e_clan_history_read_at = Time.now
    user.e_save!
  end

  def self.clan_messages(clan, page = 1)
    ClanMessage.paginate_by_clan_id_and_kind clan.id, ClanMessage::MESSAGE, :page => page
  end

  def self.send_message(clan, message, author = nil, escape = false)
    title = author ? t(:message_from, {:name => h(author.name), :id => author.id}) : ""
    message =  "#{title}  #{message}"
    ClanMessage.create! :clan => clan,
      :title => title,
      :kind => MESSAGE,
      :author => author,
      :message => escape ? h(message) : message
  end

  def self.clan_join_requests(clan, page = 1)
    ClanMessage.paginate_by_clan_id_and_kind clan.id, ClanMessage::JOIN_REQUEST, :page => page
  end

  def self.clan_join_requests_count(clan)
    ClanMessage.count :conditions => ['clan_id = ? and kind in (?)', clan.id, ClanMessage::JOIN_REQUEST]
  end

  def self.requested_join?(clan, user)
    ClanMessage.count(:conditions => ['clan_id = ? and kind = ? and author_id = ?', clan.id, JOIN_REQUEST, user.id]) > 0
  end

  def self.request_join(clan, user, message)
    ClanMessage.create! :clan => clan,
      :title => message,
      :kind => JOIN_REQUEST,
      :author => user
  end

  def self.destroy_user_join_requests(user)
    ClanMessage.destroy_all ['kind = ? and author_id = ?', ClanMessage::JOIN_REQUEST, user.id]
  end

  def self.destroy_user_clan_join_requests(user, clan)
    ClanMessage.destroy_all ['kind = ? and author_id = ? and clan_id = ? ', ClanMessage::JOIN_REQUEST, user.id, clan.id]
  end

  def self.log_donate(clan, price)
    if price.price > 0 && price.price_staff2 > 0
      key = :donate_both
    else
      if price.price_staff2 > 0
        key = :donate_staff2
      else
        key = :donate_money
      end
    end

    add_history_record ClanMessage::DONATE, clan,
      t(key, { :money => tp(price.price), :staff2 => tps2(price.price_staff2) }),
      :author => price.user
  end

  def self.last_donates(clan, page = 1)
    ClanMessage.paginate_by_clan_id_and_kind clan.id, ClanMessage::DONATE, :order => 'id desc', :page => page
  end

  def self.clan_history(clan, page = 1)
    ClanMessage.paginate_by_clan_id_and_kind clan.id, ALL_MESSAGES, :page => page
  end

  def self.log_created(clan)
    add_history_record ClanMessage::HISTORY_CREATED, clan,
      t(:clan_created, :name => clan.name), :author => clan.owner
  end

  def self.log_user_joined(clan, user)
    add_history_record ClanMessage::HISTORY_USER_JOINED, clan,
      t(:user_joined, :id => user.id, :name => user.name), :author => user
  end

  def self.log_user_kicked(clan, user)
    add_history_record ClanMessage::HISTORY_USER_KICKED, clan,
      t(:user_kicked, :id => user.id, :name => user.name), :author => user
  end

  def self.log_user_leave(clan, user)
    add_history_record ClanMessage::HISTORY_USER_LEAVE, clan,
      t(:user_leave, :id => user.id, :name => user.name), :author => user
  end

  def self.log_war_started(war)

    clan = war.clan
    opponent_clan = war.opponent_clan

    minutes = GameProperties::CLAN_WAR_PREPARATION_TIME.seconds_to_minutes

    add_history_record ClanMessage::HISTORY_WAR_STARTED, clan,
      t(:war_started, :clan_id => opponent_clan.id, :clan_name => opponent_clan.name)

    add_history_record ClanMessage::HISTORY_WAR_STARTED_OPPONENT, opponent_clan,
      t(:war_started_opponent, :clan_id => clan.id, :clan_name => clan.name)

    ClanMessage.send_message clan,
      t(opponent_clan.has_altar? ? :war_started_by_your_clan_message : :war_with_opponent_without_altar_message,
      :clan_name => opponent_clan.name,
      :clan_id => opponent_clan.id,
      :war_id => war.id,
      :minutes => minutes)

    ClanMessage.send_message opponent_clan,
      t(:war_started_message,
      :clan_name => clan.name,
      :clan_id => clan.id,
      :war_id => war.id,
      :minutes => minutes)

#    clan.union_clans.each do |union_clan|
#      ClanMessage.send_message union_clan,
#        t(:war_union_started_message, :clan_name => h(clan.name),
#        :clan_id => clan.id,
#        :opponent_clan_name => h(opponent_clan.name),
#        :opponent_clan_id => opponent_clan.id,
#        :war_id => war.id,
#        :minutes => minutes)
#    end

#    opponent_clan.union_clans.each do |union_clan|
#      ClanMessage.send_message union_clan,
#        t(:war_union_attacked_message, :clan_name => h(clan.name),
#        :clan_id => clan.id,
#        :opponent_clan_name => h(opponent_clan.name),
#        :opponent_clan_id => opponent_clan.id,
#        :war_id => war.id,
#        :minutes => minutes)
#    end

  end

  def self.log_war_finished(war)
    add_history_record ClanMessage::HISTORY_WAR_FINISHED_WIN, war.winner_clan,
      t(:war_finished_win, { :clan_name => h(war.loser_clan.name), :clan_id => war.loser_clan.id,
        :money => tp(war.winner_money),
        :staff2 => tps2(war.winner_staff2) })

    add_history_record ClanMessage::HISTORY_WAR_FINISHED_LOSE, war.loser_clan,
      t(:war_finished_lose, { :clan_name => h(war.winner_clan.name), :clan_id => war.winner_clan.id,
        :money => tp(war.winner_money),
        :staff2 => tps2(war.winner_staff2) })
  end

  def self.log_union_created(union)
    add_history_record ClanMessage::HISTORY_UNION_CREATED, union.clan2,
      t( :union_approved_by_clan, :name => h(union.clan1.name), :id => union.clan1.id )

    add_history_record ClanMessage::HISTORY_UNION_CREATED, union.clan1,
      t( :union_approved, :name => h(union.clan2.name), :id => union.clan2.id )
  end

  def self.log_union_killed(clan, second_clan)
    add_history_record ClanMessage::HISTORY_UNION_KILLED, clan,
      t( :union_killed_by_clan, :name => h(second_clan.name), :id => second_clan.id )

    add_history_record ClanMessage::HISTORY_UNION_KILLED, second_clan,
      t( :union_killed, :name => h(clan.name), :id => clan.id )
  end

  private

  def self.h(text)
    ERB::Util.h(text)
  end

  def self.add_history_record(kind, clan, message, options = {})

    options = options.dup

    ClanMessage.create! options.merge(:clan => clan,
      :title => message,
      :kind => kind)

  end

end
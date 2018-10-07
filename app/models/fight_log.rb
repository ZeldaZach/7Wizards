class FightLog < ActiveRecord::Base

  UserExt::UserAttributes
  DragonExt::DragonAttributes
  FightExt::FightRoundDetail
  
  # include base mode behaviour
  include BaseModel

  WON_EXIT_HEALTH = 1
  WON_TOTAL_DAMAGE = 16
  WON_HEALTH = 64
  WON_OPPONENT = 256

  belongs_to :user
  belongs_to :opponent, :foreign_key => "opponent_id", :class_name => "User"
  belongs_to :dragon, :foreign_key => "dragon_id", :class_name => "Dragon"

  # stored in redis
  attr_accessor :user_a, :opponent_a, :rounds, :receive_max_money_percent, :detail_info

  # override
  def after_save
    v = {
      :user => self.user_a,
      :opponent => self.opponent_a,
      :rounds => self.rounds
    }    
    @detail_info = RedisCache.put "fight_log_#{self.id}", v, 1.day
  end

  def after_find
    @detail_info = RedisCache.get "fight_log_#{self.id}"
    if @detail_info
      self.user_a     = @detail_info[:user]
      self.opponent_a = @detail_info[:opponent]
      self.rounds     = @detail_info[:rounds]
    end
  end

  def opponent_or_virtual
    opponent.nil? ? dragon : opponent
  end

  def winner()
    user_won ? user : opponent_or_virtual
  end

  def loser()
    winner == user ? opponent_or_virtual : user
  end

  def winner_a()
    user_won ? user_a : opponent_a
  end

  def loser_a()
    winner == user ? opponent_a : user_a
  end

  def winner_health_after_fight
    winner_a.a_health - winner_health_diff if winner_a
  end

  def loser_health_after_fight
    loser_a.a_health - loser_health_diff if loser_a
  end

  def user_health_after_fight
    user_won ? winner_health_after_fight : loser_health_after_fight
  end

  def opponent_health_after_fight
    user_won ? loser_health_after_fight : winner_health_after_fight
  end

  def winner_pet_health_after_fight
    [winner_a.pet_health - winner_pet_health_diff, 0].max if winner_a && winner_a.pet_health
  end

  def loser_pet_health_after_fight
    [loser_a.pet_health - loser_pet_health_diff, 0].max if loser_a && loser_a.pet_health
  end

  def user_health_diff
    user_won ? winner_health_diff : loser_health_diff
  end

  def opponent_health_diff
    !user_won ? winner_health_diff : loser_health_diff
  end

  def amulet_antimag?(user)
    (self.user == user && amulet_antimag_user?) || (self.opponent == user && amulet_antimag_opponent?)
  end

  def amulet_antimag_user?
    self.amulet_antimag_user == true
  end

  def amulet_antimag_opponent?
    self.amulet_antimag_opponent == true
  end

  def amulet_diablo_user?
    self.amulet_diablo_user == true
  end

  def amulet_diablo_opponent?
    self.amulet_diablo_opponent == true
  end

  def pet_fight?
    self.pet_fight == true
  end

  def winner_union_fight?
    user_won ? user_union_fight : opponent_union_fight
  end

  def loser_union_fight?
    user_won ? opponent_union_fight : user_union_fight
  end

  def winner_pet_reanimate
    r = user_won ? user_pet_reanimate : opponent_pet_reanimate
    !r.nil? ? r : 0
  end  

  def loser_pet_reanimate
    r = user_won ? opponent_pet_reanimate : user_pet_reanimate
    !r.nil? ? r : 0
  end

  def self.get_fights(user, page = 1, perpage = per_page)
    paginate(:conditions => ["user_id = ? OR opponent_id = ?", user.id, user.id], :order => "id DESC",
      :page => page, :per_page => perpage)
  end

  def self.get_last_fight(user)
    find :last, :conditions => {:user_id => user.id}
  end

  def can_receive_reputation?
    loser.e_last_give_reputation.nil? || loser.e_last_give_reputation < GameProperties::FIGHT_RECEIVE_REPUTATION_PER_TIME.ago
  end

  def can_receive_experience?
    (loser.e_last_give_experience.nil? || loser.e_last_give_experience < GameProperties::FIGHT_RECEIVE_EXPERIENCE_PER_TIME.ago) &&
      loser.users_count_on_level >= GameProperties::FIGHT_MIN_USERS_ON_LEVEL
  end

  def has_detail_log?
      !@detail_info.nil?
  end


end

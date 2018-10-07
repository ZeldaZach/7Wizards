class Fight::Base

  attr_reader :user, :opponent, :user_a, :opponent_a, :f

  def self.get_implementation(user, opponent)
    if user.on_war_with_user?(opponent)
      return Fight::ClanWar
    end
    Fight::Standard
  end

  def initialize
    @f = FightLog.new(
      :user => @user,
      :user_a => @user_a,
      :opponent => @opponent,
      :opponent_a => @opponent_a
    )
  end
  
  def fight_id
    @f.id
  end

  def fight!
    fight


    if !@user.virtual? && !@opponent.virtual?
      [@user, @opponent].each do |u|
        AllGameItems::ACHIVEMENT_STEALER.extend(u, @f)
        AllGameItems::ACHIVEMENT_CHAMPION.extend(u, @f)
        AllGameItems::ACHIVEMENT_DAMEGE.extend(u, @f)
        AllGameItems::ACHIVEMENT_HERO.extend(u, @f)
        AllGameItems::ACHIVEMENT_PET_KILLS.extend(u, @f) 
      end
    end
    
    @user.register_activity 'fight'
    @opponent.e_last_attacked_at = Time.now
      
    FightLog.transaction do
      @f.save!
      @user.save!
      if @opponent
        @opponent.save!
      end
    end


    @user.e_register_fight @f
    if @opponent
      @opponent.e_register_fight @f
    end
    @f
  end

  def self.set_fight_locks(user, opponent)
    RedisLock.lock "user_fight_#{user.id}" do
      if opponent.virtual?
        yield
        return true
      else
        RedisLock.lock "user_fight_#{opponent.id}" do
          yield
          return true
        end
      end
    end
    false
  end

  protected
  
  def fight

    user_health = user.a_health
    user_damage_sum = 0
    opponent_health = opponent.a_health
    opponent_damage_sum = 0

    # initial pet values, will need them in the end of fight
    user_pet_active = user.pet_active?
    user_pet_health = user.pet_health
    user_pet_damage_sum = 0
    opponent_pet_active = opponent.pet_active?
    opponent_pet_health = opponent.pet_health
    opponent_pet_damage_sum = 0

    pet_fight = user_pet_active && opponent_pet_active

    can_pet_fight_user = lambda do |u|
      if u == user
        user_pet_active && user_pet_health > 0 &&
          (opponent_pet_health <= 0 || !opponent_pet_active) 
      else
        opponent_pet_active && opponent_pet_health > 0 &&
          (user_pet_health <= 0 || !user_pet_active) 
      end
    end

    #    antipet_triggered = lambda do |u|
    #      if u == user
    #        AllGameItems::ANTIPET.is_active?(user) && can_pet_fight_user.call(opponent)
    #      else
    #        AllGameItems::ANTIPET.is_active?(opponent) && can_pet_fight_user.call(user)
    #      end
    #    end

    #    f.amulet_antimag_user = false #Inventories::Amulets::ANTIMAG.use?(user)
    #    f.amulet_antimag_opponent = false #Inventories::Amulets::ANTIMAG.use?(opponent)

    fights = [] # list of all fight details

    GameProperties::FIGHT_PROCESS_ROUNDS.times do

      # if both have pets pets strike each other
      if pet_fight && user_pet_health > 0 && opponent_pet_health > 0
        user_fight = round_pet_attack(f, user, opponent)
        opponent_pet_health -= user_fight.damage
        user_pet_damage_sum += user_fight.damage
        user_fight.pet_killed = opponent_pet_health <= 0
        fights << user_fight
      end

      user_fight = round_attack user, opponent, can_pet_fight_user.call(user)
      opponent_health -= user_fight.damage
      user_damage_sum += user_fight.damage
      fights << user_fight
      break if opponent_health < GameProperties::FIGHT_PROCESS_EXIT_HEALTH

      # if both have pets pets strike each other
      if pet_fight && user_pet_health > 0 && opponent_pet_health > 0
        opponent_fight = round_pet_attack(f, opponent, user)
        user_pet_health -= opponent_fight.damage
        opponent_pet_damage_sum += opponent_fight.damage
        opponent_fight.pet_killed = user_pet_health <= 0
        fights << opponent_fight
      end

      opponent_fight = round_attack opponent, user, can_pet_fight_user.call(opponent)
      user_health -= opponent_fight.damage
      opponent_damage_sum += opponent_fight.damage
      fights << opponent_fight
      break if user_health < GameProperties::FIGHT_PROCESS_EXIT_HEALTH

    end

    f.user_won = fight_update_winner user_damage_sum + user_pet_damage_sum,
      opponent_damage_sum + opponent_pet_damage_sum,
      user_health, opponent_health
    f.rounds = fights

    # if both pets were active in the beginning of fight
    fight_update_result_pet_health(user_pet_health, opponent_pet_health) if pet_fight

    fight_update_result_health user_health, opponent_health
    fight_update_auto_regenerate_health
    fight_update_result_money
    fight_update_wins_statistics
    #TODO when monster will be implemented
    #    fight_update_result_staff2
    fight_update_result_experience_and_reputation

    fight_update_fights_count
  end

  # Итоговый урон: (Количество урона – количество заблокированного урона) Минусовое число приравнивается к 0
  def round_attack(user, opponent, user_pet)

    d = FightExt::FightRoundDetail.new
    d.user = self.user == user
    d.pet_fight = user_pet.nil?

    pet_damage = 0;

    # if user has pet and opponent has no pet.
    # pet can strike opponent
    if user_pet
      u = user_attributes user
      o = user_attributes opponent
      
      if AllGameItems::ANTIPET.is_active?(opponent)
        d.anti_pet_opponent = true
      else
        pet_damage = u.full_pet_power
      end
    end

    user_damage = 0;
    blocked_damage = 0;
    stroke = false
    critical = false
    if is_stroke(d, user, opponent)
      stroke = true
      blocked_damage = get_blocked_damage(d, opponent)
      if is_critical_stroke(d, user, opponent)
        user_damage = get_critical_damage(d, user)
        critical = true
      else
        user_damage = get_damage(d, user)
      end
    end

    d.damage = pet_damage + [user_damage - blocked_damage, 0].max     # final damage
    d.real_damage = user_damage                                       # damage without block
    d.blocked_damage = blocked_damage                                 # blocked dabage
    d.critical = critical                                             # critical or non critical strike
    d.stroke = stroke                                                 # stroke or not stroke
    d.pet_damage = pet_damage                                         # pet damage

    d
  end

  # Итоговый урон: (Количество урона – количество заблокированного урона) Минусовое число приравнивается к 0
  def round_pet_attack(f, user, opponent)
    round_attack(user, opponent, nil)
  end

  def is_stroke(d, user, opponent)
    u = user_attributes user
    o = user_attributes opponent

    rnd = rand

    if d.pet_fight
      # Вероятность попадания: мастерство нападающего х 2 / (мастерство нападающего х 2 + ловкость защищающегося)
      stroke = (u.full_pet_skill.to_f * 2.0) / (u.full_pet_skill.to_f * 2.0 + o.pet_dexterity.to_f)
      r = stroke >= rnd
    else
      # Вероятность попадания: мастерство нападающего х 2 / (мастерство нападающего х 2 + ловкость защищающегося)
      stroke = (u.full_skill.to_f * 2.0) / (u.full_skill.to_f * 2.0 + o.full_dexterity.to_f)
      r = stroke >= rnd

      # Ловкий пупс - Повышает вероятность уклонения от удара на X %. Действует постоянно.
      pups_percent = 0
      if r && !f.amulet_antimag?(user)
        pups_percent = UserItems::AmuletPups.get_percent(opponent)
        d.amulet_pups_opponent = stroke - pups_percent < rnd
        r = !d.amulet_pups_opponent
      end
    end

    r
  end

  def is_critical_stroke(d, user, opponent)
    u = user_attributes user
    o = user_attributes opponent

    rnd = rand

    if d.pet_fight
      # Вероятность критического удара = мастерство нападающего/(мастерство нападающего + ловкость защищающегося)
      critical_stroke = u.full_pet_skill.to_f / ( u.full_pet_skill.to_f + o.pet_dexterity.to_f )
      r = critical_stroke >= rnd
    else
      # Вероятность критического удара = мастерство нападающего/(мастерство нападающего + ловкость защищающегося)
      critical_stroke = u.full_skill.to_f / ( u.full_skill.to_f + o.full_dexterity.to_f )
      r = critical_stroke >= rnd

      # Какдамс - Повышает вероятность нанести критический удар на X %. Действует постоянно.
      if !r && !f.amulet_antimag?(opponent)
        kakdams_percent = UserItems::AmuletKakdams.get_percent(user)
        d.amulet_kakdams_user = critical_stroke + kakdams_percent >= rnd
        r = d.amulet_kakdams_user
      end
    end

    r
  end

  # Количество урона = Random(сила нападающего/2; сила нападающего*3/2)
  def get_damage(d, user)
    u = user_attributes user

    # rand(1/2 -> 3/2) => rand(1) + 1/2
    if d.pet_fight
      r = rand(u.full_pet_power) + 0.5 * u.full_pet_power
    else
      r = rand(u.full_power) + 0.5 * u.full_power
    end

    r.round
  end

  # Количество критического урона = количество урона*2
  def get_critical_damage(d, user)
    get_damage(d, user) * 2
  end

  # Количество заблокированного урона = Random(защита защищающегося/2;защита защищающегося)
  def get_blocked_damage(d, opponent)
    o = user_attributes opponent

    # rand(1/2 -> 1) => rand(1/2) + 1/2
    if d.pet_fight
      r = (0.5 * o.pet_protection).round
    else
      r = (0.5 * o.full_protection).round
    end

    rand(r) + r
  end

  def fight_update_winner(total_user_damage, total_opponent_damage, user_health, opponent_health)

    if user_health <= GameProperties::FIGHT_PROCESS_EXIT_HEALTH
      f.won_reason = FightLog::WON_EXIT_HEALTH
      return false
    else
      if opponent_health <= GameProperties::FIGHT_PROCESS_EXIT_HEALTH
        f.won_reason = FightLog::WON_EXIT_HEALTH
        return true
      end
    end

    if total_user_damage > total_opponent_damage
      f.won_reason = FightLog::WON_TOTAL_DAMAGE
      return true
    else
      if total_opponent_damage > total_user_damage
        f.won_reason = FightLog::WON_TOTAL_DAMAGE
        return false
      end
    end

    if user_health > opponent_health
      f.won_reason = FightLog::WON_HEALTH
      return true
    else
      if opponent_health > user_health
        f.won_reason = FightLog::WON_HEALTH
        return false
      end
    end

    f.won_reason = FightLog::WON_OPPONENT
    return false
  end

  def fight_update_result_health(user_health, opponent_health)

    user_health_diff = user_health > GameProperties::FIGHT_PROCESS_EXIT_HEALTH ?
      user.a_health - user_health : user.a_health - GameProperties::FIGHT_PROCESS_EXIT_HEALTH

    #    f.amulet_diablo_user = Inventories::Amulets::DIABLO.use?(f.user)
    #    user_health_diff = 0 if f.amulet_diablo_user?

    user.a_health -= user_health_diff

    opponent_health_diff = opponent_health > GameProperties::FIGHT_PROCESS_EXIT_HEALTH ?
      opponent.a_health - opponent_health : opponent.a_health - GameProperties::FIGHT_PROCESS_EXIT_HEALTH

    #    f.amulet_diablo_opponent = Inventories::Amulets::DIABLO.use?(f.opponent)
    #    opponent_health_diff = 0 if f.amulet_diablo_opponent?

    opponent.a_health -= opponent_health_diff

    f.winner_health_diff, f.loser_health_diff =
      winner_loser_values user_health_diff, opponent_health_diff

    f.winner.s_lost_protection += f.winner_health_diff
    f.winner.s_total_damage += f.loser_health_diff

    f.loser.s_lost_protection += f.loser_health_diff
    f.loser.s_total_damage += f.winner_health_diff
  end

  def fight_update_result_pet_health(user_pet_health, opponent_pet_health)
    f.pet_fight = true

    user_pet_health_diff = user.pet_health - user_pet_health
    opponent_pet_health_diff = opponent.pet_health - opponent_pet_health

    user.pet_health = [user_pet_health, 0].max
    opponent.pet_health = [opponent_pet_health, 0].max

    if AllGameItems::ANTIKILLER.reanimate(f.user, user_a.pet_health)
      f.user_pet_reanimate = user_a.pet_health
    end

    if  AllGameItems::ANTIKILLER.reanimate(f.opponent, opponent_a.pet_health)
      f.opponent_pet_reanimate = opponent_a.pet_health
    end

    f.winner_pet_health_diff, f.loser_pet_health_diff = 
      winner_loser_values user_pet_health_diff, opponent_pet_health_diff
    
    f.winner_pet_killed, f.loser_pet_killed =
      winner_loser_values user.pet_is_dead?, opponent.pet_is_dead?

    if user.pet_is_dead? 
      opponent.s_kill_pets += 1
      user.s_lose_pets += 1
    end

    if opponent.pet_is_dead? && user.can_receive_bonus_for_kill_pet?(opponent)
      user.s_kill_pets += 1
      opponent.s_lose_pets += 1
    end
  end

  def fight_update_auto_regenerate_health
    min_health = GameProperties::FIGHT_OPPONENT_MINIMAL_HEALTH
    user.a_health = min_health if user.a_health < min_health
    opponent.a_health = min_health if opponent.a_health < min_health
  end

  def fight_update_result_money
    last_give_money = f.loser.e_last_give_hight_percent_money
    delay_time = GameProperties::FIGHT_PROCESS_CAN_EARN_MONEY_MANY_DELAY.ago

    # we can get 10% of loser money one per 2 hours
    if (last_give_money && last_give_money > delay_time)
      money_percent_to_receive = 1
    else
      money_percent_to_receive = GameProperties::FIGHT_EARN_MONEY_PER_LEVELS.call(f.winner.a_level, f.loser.a_level)
      f.receive_max_money_percent = true
    end

    unsafe_money = AllGameItems::SAFE.get_unsafe_money(f.loser)                           # some money can be protected by safe

    # if user has loot gift then we should use it
    money_percent_to_receive = UserItems::ShopGiftLootMoney.get_money_receive_percent f.winner, money_percent_to_receive

    money_to_receive = unsafe_money.percent_of(money_percent_to_receive)
    if money_to_receive < GameProperties::FIGHT_PROCESS_MIN_MONEY_TO_RECEIVE
      money_to_receive = GameProperties::FIGHT_PROCESS_MIN_MONEY_TO_RECEIVE
    end

    money_to_receive = f.loser.a_money if f.loser.a_money - money_to_receive < 0                  # if user has less then money we should get. we'll get all
    money_to_receive = [money_to_receive, 0].max                                                  # some users can hack and have - on their accounts.

    f.winner_money_diff = money_to_receive
    f.loser_money_diff = -money_to_receive

    if f.user_won
      user.add_money(money_to_receive, "fight won")
      opponent.spend_money(money_to_receive, "fight lost")
    else
      opponent.add_money(money_to_receive, "fight won")
      user.spend_money(money_to_receive, "fight lost")
    end
  end

  def fight_update_wins_statistics
    f.winner.s_wins_count += 1
    f.winner.s_loot_money += f.winner_money_diff

    f.loser.s_loses_count += 1
    f.loser.s_lost_money += f.winner_money_diff
  end

  def fight_update_result_staff2
    unsafe_staff = AllGameItems::SAFE2.get_unsafe_money(f.loser) # some money can be protected by safe
    staff_to_receive = unsafe_staff > 0 ? 1 : 0

    f.winner_staff2_diff = staff_to_receive

    if staff_to_receive > 0
      f.winner.a_staff2 += staff_to_receive
      f.winner.s_loot_staff2 += staff_to_receive

      f.loser.a_staff2 -= staff_to_receive
      f.loser.s_lost_staff2 += staff_to_receive
    end
  end

  def fight_update_result_experience_and_reputation

    f.winner_experience = 0
    f.winner_reputation = 0

    w = f.winner
    l = f.loser

    if f.can_receive_experience?
      # calculate experience
      if w.a_level == l.a_level
        f.winner_experience = 1
      else
        if w.a_level < l.a_level
          f.winner_experience = 2
        end
      end

      w.a_experience += f.winner_experience
    end

    if f.can_receive_reputation? 
      # calculate reputation
      if w.a_level == l.a_level
        # with probability 33.33% you'll receive reputation in this case
        if rand(3) == 0
          f.winner_reputation = 1
        end
      else
        if w.a_level < l.a_level
          f.winner_reputation = 1

          #NOT NEED DECREASE REPUTATION
#        else
#          # if user attached opponent with 3 levels lower we should decrease his reputation
#          reputation_level_diff = GameProperties::FIGHT_REPUTATION_LEVEL_DIFF
#          if f.user_won && w.a_level > l.a_level + reputation_level_diff
#            f.winner_reputation = - [w.a_reputation, w.a_level - l.a_level - reputation_level_diff].min
#          end
        end
      end

      w.a_reputation += f.winner_reputation
    end
  end

  def fight_update_fights_count
    @user.e_fights_count -= 1
  end

  def user_attributes(user)
    user == self.user ? user_a : opponent_a
  end

  def winner_value(user_value, opponent_value)
    f.user_won ? user_value : opponent_value
  end

  def loser_value(user_value, opponent_value)
    f.user_won ? opponent_value : user_value
  end

  def winner_loser_values(user_value, opponent_value)
    w = winner_value user_value, opponent_value
    l = loser_value user_value, opponent_value
    [w, l]
  end

end

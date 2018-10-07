class GameProperties
  PROD = ENV['RAILS_ENV'] == 'production'
  PROD_OR_TEST = PROD || ENV['RAILS_ENV'] == 'test'

  PRODUCTION_HOST = "http://www.7wizards.com"

  #for ajax mode change to ":ajax => true"
  DEVELOPMENT_MODES = {
    :ajax  => true,
    :chat  => true,
    :games => false
  }
  
  def self.is_enabled_mode?(type)
    DEVELOPMENT_MODES[type] || PROD_OR_TEST
  end

  GLOBAL_URLS = {
    :privacy  => "http://www.7wizards.com/static/privacy.html",
    :terms    => "http://www.7wizards.com/static/terms.html",
    :rules    => "http://www.7wizards.com/static/rulles.html",
    :blog_faq => "http://blog.7wizards.com/search/label/FAQ",
    :blog     => "http://blog.7wizards.com/"
  }

  EVENTS_LIVE_TIME = 2.days
  
  USER_ACTIVE_PERIOD = 40.minutes               # we think that user is active when he perform last action this time ago.
  USER_HOLIDAY_TIME = 5.days                    # after 5 days from last activity we'll send user on holiday
  TIME_BETWEEN_USER_HOLIDAYS = 2.weeks          # user can go on holiday once per 2 weeks
  USER_HOLIDAY_MIN_DURATION = 48.hours
  USER_REGISTRATION_FIGHT_FREE_TIME = 48.hours  # you can't find user during this time after registration using random search

  # user properties
  USER_INITIAL_LEVEL = 1
  USER_INITIAL_MONEY = 500
  USER_INITIAL_STAFF = 0
  USER_INITIAL_STAFF2 = 3
  USER_INITIAL_REPUTATION = 0
  USER_INITIAL_EXPERIENCE = 1
  USER_INITIAL_HEALTH = 100
  USER_INITIAL_POWER = 5
  USER_INITIAL_PROTECTION = 5
  USER_INITIAL_DEXTERITY = 5
  USER_INITIAL_WEIGHT = 5
  USER_INITIAL_SKILL = 5
  USER_INITIAL_FIGHTS = 3
  USER_INITIAL_PLANTATION = 0
  USER_INITIAL_PLACES = 0
  USER_INITIAL_FENCE = 0
  USER_INITIAL_CLAIRVOYANCE = 0
  USER_INITIAL_CLOAKING = 0

  REFERENCE_BONUS_STAFF = 50
  REFERENCE_BONUS_LEVEL = 7
  REFERENCE_BONUS_COUNT = 20
  REFERENCE_BONUS_PAYMENTS_PERCENT = 20

  GAME_PLANTATION_ITEM_SCALE = [ [80, 12000, 0], # money to receive each hour, price in money to move on next level, price in staff
    [240, 21000, 0],
    [400, 32080, 0],
    [640, 41280, 0],
    [940, 63120, 0],
    [1240, 0, 1950],
    [1540, 0, 2700],
    [2040, 0, 3450],
    [2340, 0, 4200],
    [3040, 0, 4950],
    [3440, 0, 0] ]

  GAME_MONEY_LIMIT_LEVELS = (1..10).to_a
  GAME_MONEY_LIMIT_COEFICIENT = 5000         # users of limit levels can earn max level * coeficient money 

  GAME_MAX_ITEMS_PLACES = 50
  #  GAME_PLACES_ITEM_SCALE = [ [4, 10], # number of places, price to move on next level
  #                         [6, 50],
  #                         [8, 220],
  #                         [10, 715],
  #                         [12, 4185],
  #                         [14, 15920],
  #                         [16, 81830],
  #                         [18, 412175],
  #                         [22, 1978715],
  #                         [24, 9321320],
  #                         [28, 0] ]

  GAME_FENCE_ITEM_SCALE = [ [2, 0, 5], # armour, armour percents, price to move on next level
    [4, 0, 25],
    [6, 0, 120],
    [8, 2, 515],
    [10, 2, 5765],
    [12, 2, 13125],
    [14, 3, 59885],
    [16, 3, 293210],
    [18, 3, 1632125],
    [20, 4, 6834235],
    [22, 5, 0] ]

  # money to move on next level
  GAME_CLAIRVOYANCE_ITEM_SCALE = [5, 20, 65, 250, 1020, 4000, 16000, 65500, 260100, 1050500]

  # money to move on next level
  GAME_CLOAKING_ITEM_SCALE =  [5, 20, 65, 250, 1020, 4000, 16000, 65500, 260100, 1050500]

  GAME_SAFE_ITEM_CONFIG = {
    :price => 0,
    :price_staff => 200,
    :time => 10.days,
    :scale => [ [1, 2,   1330  ], # from level, to level, money
      [3, 6,   2660  ],
      [7, 14,  5320  ],
      [15, 19, 10640 ],
      [20, 24, 15960 ],
      [25, 29, 21280 ],
      [30, 34, 31920 ],
      [35, 39, 42560 ],
      [40, 44, 63840 ],
      [45, 49, 85120 ],
      [50, 54, 112360],
      [55, 59, 146300],
      [60, 64, 179550],
      [65, 69, 226100],
      [70, 74, 266000],
      [75, 79, 305900] ]
  }

  GAME_SAFE2_ITEM_CONFIG = {
    :price => 0,
    :price_staff => 100,
    :time => 120.hours,
    :scale => [ [1, 100, 30] ]
  }
  
  GAME_POWER_ITEM_CONFIG = {
    :price_staff => 90,
    :time => 36.hours,
    :power_percents => 50
  }

  GAME_PROTECTION_ITEM_CONFIG = {
    :price_staff => 70,
    :time => 36.hours,
    :protection_percents => 50
  }

  GAME_ENDURANCE_ITEM_CONFIG = {
    :price_staff => 90,
    :time => 12.hours
  }

  GAME_PET_POWER_ITEM_CONFIG = {
    :price_staff => 90,
    :time => 24.hours,
    :power_percents => 50
  }

  GAME_ANTIPET_ITEM_CONFIG = {
    :price_staff => 90,
    :time => 48.hours
  }

  GAME_PET_ANTIKILLER_ITEM_CONFIG = {
    :price_staff => 90,
    :time => 24.hours,
    :regenerate_percent => 100
  }

  GAME_VOODOO_ITEM_CONFIG = {
    :price_staff => 100,
    :time => 24.hours
  }

  GAME_PET_ANTIKILLER_MONTH_USE_LIMITATION = 10
  GAME_PET_ANTIPET_MONTH_USE_LIMITATION = 10
  GAME_VOODOO_MONTH_USE_LIMITATION = 7
  
  # patrol options
  #  MEDITATION_PRICE = 0
  #  MEDITATION_RECEIVE_STAFF_PROC = proc { |time|
  #    r = 0
  #    (time.to_i / 10.minutes).times do
  #      r += 1 if rand <= 0.03
  #    end
  #    r
  #  }

  # depends on level user can earn different amount of money in patrol
  #  MEDITATION_MONEY_PROC = proc { |level| (level * 200 * (level * 0.1 + 1)).to_i }
  #  MEDITATION_RICH_GUY_POSIBILITY = 5          # with this probability you can find rich guy in patrol
  #  MEDITATION_RICH_GUY_MONEY_PROC = proc { |level| level * 500 }

  MEDITATION_MAX_TIME = 360.minutes # 3 hours
  MEDITATION_TIMES_TO_GO = [ {:time => 10.minutes, :display => I18n.t('time.minutes', {:count => 10})},
    {:time => 20.minutes, :display => I18n.t('time.minutes', {:count => 20})},
    {:time => 30.minutes, :display => I18n.t('time.minutes', {:count => 30})},
    {:time => 60.minutes, :display => I18n.t('time.minutes', {:count => 60})},
    {:time => 120.minutes, :display => I18n.t('time.minutes', {:count => 120})},
    {:time => 240.minutes, :display => I18n.t('time.minutes', {:count => 240})},
    {:time => 360.minutes, :display => I18n.t('time.minutes', {:count => 360})}]
  
  MEDITATION_EXPERIENCE = 1              # experience to receive per 10 min
  MEDITATION_NIRVANA_PROBABILITY = 0.05  # in percents

  DAILY_BONUS_POSSIBILITY_GET_HIGH = 0.05
  DAILY_BONUS_LOW = [20, 100]
  DAILY_BONUS_HIGHT = [150, 300]
  #  DAILY_BONUS_MONEY_COEFF = 500 #Coeficient for money bonus rand(coeff) * a_level
  
  # fight properties
  FIGHT_FIND_PRICE = 5
  FIGHT_MINIMAL_HEALTH = 80
  FIGHT_OPPONENT_MINIMAL_HEALTH = 40
  FIGHT_HEALTH_REGENERATION_SPEED = 3 # if user has health less then FIGHT_OPPONENT_MINIMAL_HEALTH regeneration will work X times faster
  FIGHT_MAX_FIGHTS_COUNT = 3
  FIGHT_MAX_FIGHTS_COUNT_PER_DAY = 160
  FIGHT_REGENERATION_TIME = 12.minutes
  FIGHT_ADVANCED_MAX_FIGHTS_COUNT = 6
  FIGHT_ADVANCED_REGENERATION_TIME = 6.minutes
  FIGHT_MINIMAL_MONEY = 10
#  FIGHT_REPUTATION_LEVEL_DIFF = 2
  FIGHT_MIN_REPUTATION_TO_FIGHT_LOSERS = 5 # if user has reputation less then this number he can't fight losers
  FIGHT_MIN_LEVEL_DIFF_TO_FIGHT = 5
  FIGHT_WITH_OPPONENT_AND_YOU_PERIOD = 60.minutes
  FIGHT_WITH_OPPONENT_PERIOD = 45.minutes
  FIGHT_MAX_FIGHTS_WITH_OPPONENT_PER_DAY = 6
  FIGHT_MAX_USER_FIGHTS_PER_DAY = 40
  FIGHT_RECEIVE_REPUTATION_PER_TIME = 2.hours
  FIGHT_RECEIVE_EXPERIENCE_PER_TIME = 2.hours
  FIGHT_MIN_USERS_ON_LEVEL = 10
  FIGHT_PET_LEVEL_DIFF = 2

  # fight process constants
  FIGHT_PROCESS_ROUNDS = 3
  FIGHT_PROCESS_EXIT_HEALTH = 1
#  FIGHT_PROCESS_CAN_EARN_MONEY_PERCENT_MANY = 10 # user can earn 10% if win once per 2 hours
#  FIGHT_PROCESS_CAN_EARN_MONEY_PERCENT_LITTLE = 1 # else 1 percent

  FIGHT_EARN_MONEY_PER_LEVELS = proc do |user_level, opponent_level|
    percent = 15
    if user_level == opponent_level
      percent = 10
    elsif user_level > opponent_level 
      percent = (user_level - opponent_level) > 2 ? 1 : 5
    end
    percent
  end

  FIGHT_PROCESS_CAN_EARN_MONEY_MANY_DELAY = 2.hours
  FIGHT_PROCESS_MIN_MONEY_TO_RECEIVE = 3

  #  MODERATOR_BAN_DAYS_CHAT = 2         # moderator can ban users on this amount of days on chat page
  #  MODERATOR_BAN_DAYS_PROFILE = 2      # moderator can ban users on this amount of days on profile page
  #  MODERATOR_DAY_BAN_COUNT = 10        # max amout of bans per day

  MIN_LEVEL_TO_EDIT_MESSAGES = 3

  CHAT_MIN_LEVEL = 3                  # users can talk in chat from this level
  CHAT_PUBLIC_NAME = "public"
  CHAT_LAST_MESSAGES_COUNT = 20
  CHAT_ACTIVITY_TIME = 10.minutes

  #predefined smiles
  CHAT_SMILEYS = {
    ':)' => '01',
    ':-)' => '01',
    ':-(' => '03',
    ':(' => '03',
    ';)' => '04',
    ';-)' => '04',
    ':-P' => '05',
    ':P' => '05',
    '8-)' => '06',
    ':D' => '07',
    ':-[' => '08',
    '=-o' => '09',
    '*IN LOVE*' => '10',
    ':-*' => '11',
    '@=' => '12',
    '*DRINK*' => '13',
    '*THUMBS*' => '14',
    '*ROFL*' => '15',
    '*HAPPY*' => '16',
    '*STOP*' => '17',
    '*WASSUP*' => '18',
    ':-X' => '19',
    ':-/' => '20',
    '*DEVIL BOY*' => '21',
    '*KISSED*' => '23',
    ':-!' => '24',
    '*KISSING*' => '25',
    '*THUMS UP*' => '26',
    '%)' => '27',
    '*BRAVO*' => '28',
    '*CRAZY*' => '29',
    '*DONT_KNOW*' => '30',
    '*DANCE*' => '31',
    '*HI*' => '32',
    '*BYE*' => '33',
    '*WRITE*' => '34',
    '*SCRATCH*' => '35',
    '*PARTY*' => '36',
    '*EGIPT_DANCE*' => '38',
    '*HOUNTING*' => '39',
    '*ROCK*' => '40',
    '*BACK*' => '41',
    '*TRAIN*' => '42',
    '*MUSCULES*' => '43',
    '*ANGRY*' => '44',
    '*BRUISE*' => '45',
    '*NO-N0*' => '46',
    '*MUSIC*' => '47',
    '*GLASSES*' => '48',
    '*HOT*' => '49',
    '*FLOWER*' => '50',
    '*COUPLE*' => '51',
    '*MORALITY*' => '52',
    '*HIDE*' => '53',
    '*SHE_DANCE*' => '54',
    '*CRYING*' => '55',
    '*GANSTER*' => '56',
    '*DEVIL*' => '57',
    '*QUIN*' => '58',
    '*KING*' => '59',
    '*RULLES*' => '60',
    '*SLIP*' => '61',
  }

  CHAT_BAN_TIMES_MAX = 2.days
  CHAT_BAN_TIMES = [ {:time => 1.hours, :display => I18n.t('time.hours', {:count => 1})},
    {:time => 1.days,  :display => I18n.t('time.days',  {:count => 1})},
    {:time => 2.days,  :display => I18n.t('time.days',  {:count => 2})}]
  
  CHAT_REPORT_RESTRICTION_TIME = 5.hours

  CLAN_INITIAL_MONEY = 0
  CLAN_INITIAL_STAFF2 = 0
  CLAN_CHANGE_PRICE = 500

  CLAN_MIN_JOIN_LEVEL = 3
  CLAN_MIN_CREATE_LEVEL = 5
  CLAN_MAX_JOINS_PER_MONTH = 10                     # clan owner can allow this amount of joins per month
  CLAN_TIME_BETWEEN_CLAN_JOINS_ON_LEAVE = 2.days

  CLAN_PLACES_ITEM_SCALE = [ [ 3,  1210 ], # number of places
    [ 5,  5485 ],
    [ 7,  12985 ],
    [ 9,  35320 ],
    [ 12, 63220 ],
    [ 14, 126440 ],
    [ 16, 252880 ],
    [ 18, 505760 ],
    [ 20, 0 ] ]

  CLAN_PROTECTION_ITEM_SCALE = [ [ 0,    20000 ],  # % of protection, price in money
    [ 0.5,  40000 ],
    [ 1,    80000 ],
    [ 1.5,  160000 ],
    [ 2,    320000 ],
    [ 2.5,  640000 ],
    [ 3,    1280000 ],
    [ 3.5,  2560000 ],
    [ 4,    5120000 ],
    [ 4.5,  10240000 ],
    [ 5,    0 ] ]

  CLAN_POWER_ITEM_SCALE = [ [ 0,    20000 ],  # % of online users power, price in money
    [ 0.5,  40000 ],
    [ 1,    80000 ],
    [ 1.5,  160000 ],
    [ 2,    320000 ],
    [ 2.5,  640000 ],
    [ 3,    1280000 ],
    [ 3.5,  2560000 ],
    [ 4,    5120000 ],
    [ 4.5,  10240000 ],
    [ 5,    0 ] ]

  CLAN_ALTAR_ITEM_SCALE = [ [ 0,  10000 ], # number of wars per month, price in money
    [ 1,  40000 ],
    [ 2,  120000 ],
    [ 3,  360000 ],
    [ 4,  0 ]]

  CLAN_MIN_USERS_TO_START_WAR = 5
  OPPONENT_CLAN_MIN_USERS_TO_START_WAR = 5
  CLAN_MAX_WAR_DURATION_TIME = 72.hours
  CLAN_REST_TIME_AFTER_WAR = 1.day
  CLAN_WAR_WINNER_REPUTATION_BONUS = 2              # + reputation for each user of winner clan
  CLAN_WAR_MAX_STARTED_WARS_BY_OPPONENTS = 10
  CLAN_WARS_WITH_THE_SAME_CLAN_PERIOD = 2.weeks
  CLAN_WAR_PREPARATION_TIME = 30.minutes
  CLAN_WAR_PROTECTION_COEFICIENT = 6
  CLAN_WAR_PROTECTION_COEFICIENT_OPPONENT = 7
  CLAN_WAR_MIN_HEALTH_FOR_WIN = 50
  CLAN_WAR_MINUS_REPUTATION_WITHOUT_ALTAR = 10

  PET_BUY_PRICE_STAFF = 300
  PET_REANIMATE_PRICE_STAFF = 300
  PET_MIN_WEIGHT_TO_PUT_OUT = 20

  KILL_PET_SKILL_BONUS = proc { |skill, killed|
    k = (killed.to_i / 10);
    k = 10 if k > 10
    k.to_i * 3
  }

  PRESENT_MAX = 12                                 # user can store maximum X active presents
  PRESENT_SENT_DAY_LIMIT_TO_USER = 3              # it's allowed to send only X presents per day to particular user
  PRESENT_SENT_DAY_LIMIT_TO_ALL = proc { |user|   # it's allowed to send only X presents per day
    return 20 if user.a_level > 20
    return 15 if user.a_level > 14
    return 10 if user.a_level > 10
    5
  }
  PRESENT_MAX_RECEIVE_PER_DAY = 20                # user can receive maximum X presents per day

  PROMOTION_BY_USER_INFO_SOURCE = {
    :chobots => {
      :paid => {:staff_bonus => 300},
      :active => {:staff_bonus => 300}
    } #user comes from chobots, receive bonus 200 gold
  }

  USER_MAX_USED_AMULETS = 2

  TUTORIAL_PRICE = 60 #user receive 60 mana for every done task

  DRAGON_MIN_HEALTH = 5             # when dragon health is less then this value he'll die
  DRAGON_MIN_USER_LEVEL = 5         # user can fight with dragon from this level
#  DRAGON_ARRIVE_PROBABILITY = 70    # dragon will arrive every day with this probability
  DRAGON_TIME = 1.hour              # during this time users can fight with dragon when he arrives
  DRAGON_ARRIVE_FROM = 1.hours      # time when dragon can arrive from
  DRAGON_ARRIVE_TO = 22.hours       # time when dragon can arrive to

  DRAGON_LAST_PROBABILITY_PERCENT = 20
  DRAGON_MIN_LEVEL = 27
  DRAGON_MAX_LEVEL = 30

  # dragon health by level
  DRAGON_HEALTH = proc do |level|
   (2000 + level * 500)
  end

  # dragon money per level
  DRAGON_MONEY = proc do |level, previous_money|
    if level == 1
      r = 9000
    elsif level <= 10
      r = (1.1 * previous_money).to_i + 1500
    elsif level <= 20
      r = (1.2 * previous_money).to_i
    else
      r = (1.015 * previous_money).to_i
    end

    r
  end

  # double health probability percent, double power probability percent, double power kill bonus
  DRAGON_DOUBLE_HEALTH_DOUBLE_POWER_AND_BONUS = proc do |level|
    return [5, 10, 20] if level <= 10
    return [7.5, 7.5, 50] if level <= 20
    [10, 5, 100]
  end

  #achivements scale
  ACHIVEMENT_ELDERS_SCALE     = [1]
  ACHIVEMENT_MEDITATION_SCALE = [10, 25, 50, 100, 200, 300, 500, 1000, 1500, 2000] #meditation hours
  ACHIVEMENT_STEALER_SCALE    = [100, 1000, 5000, 10000, 50000, 100000, 500000, 1000000, 2000000, 5000000] #win money
  ACHIVEMENT_CHAMPION_SCALE   = [10, 25, 50, 100, 200, 500, 1000, 2000, 5000, 10000] #wins count
  ACHIVEMENT_DAMAGE_SCALE     = [100, 1000, 5000, 10000, 50000, 100000, 500000, 1000000, 2000000, 5000000] #made a damage
  ACHIVEMENT_HERO_SCALE       = [10, 20, 50, 100, 150, 250, 500, 1000, 1500, 2000] #earning fame
  ACHIVEMENT_PET_KILLS_SCALE  = [1, 5, 10, 15, 25, 40, 60, 85, 115, 150] #kill pets
  ACHIVEMENT_WON_WARS_SCALE   = [1, 3, 6, 10, 15, 20, 30, 50, 75, 100] #won clan wars
  ACHIVEMENT_DRAGONS_SCALE    = [100, 1000, 2500, 5000, 10000, 20000, 50000, 100000, 250000, 500000] #make dragons damage
  ACHIVEMENT_GIFTS_SCALE      = [1, 10, 25, 50, 100, 250, 500, 1000, 1500, 2000] #sent gifts for different friends

  HI5_EXCHANGE = 2
  BIGPOINT_PRODUCTS = {"600" => "5.99", "2400" => "17.99", "5400" => "35.99"}

  AVATAR_VOTING_PER_DAY_MAX = 10
  AVATAR_VOTING_MIN_LEVEL   = 3
end


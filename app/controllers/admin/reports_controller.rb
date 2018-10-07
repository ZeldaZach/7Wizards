class Admin::ReportsController < AdminController

  def config
    @config_path = params[:config_path]
    @config_path = "lib/game_properties.rb" if @config_path.nil? || @config_path == ""

    @content = ""
    File.open(Rails.root + @config_path, "r") do |f|
      while line = f.gets
        @content += line
      end
    end
  end

  def reports
    @name = params[:name].blank? ? "top_users" : params[:name]
    @name = "report_" + @name
    @content = eval("self.#{@name}")
  end

  protected

  def report_top_users
    sql = <<-SQL
      select name, a_level, a_experience, a_reputation from users order by a_level desc, a_experience desc, a_reputation asc limit 20
    SQL
    execute sql
  end

  def report_buy_gold_days
    t = Time.now.advance(:days => -31)
    time = t.to_formatted_s :db
    sql = <<-SQL
      SELECT DATE_FORMAT(h.created_at,'%Y-%m-%d') as DayOfMonth, sum(h.price) as _sum_$ FROM payment_logs h
      where h.kind = #{PaymentLog::BUY_STAFF} and h.created_at > '#{time}' GROUP BY 1 order by DayOfMonth desc;
    SQL
    execute sql
  end

  def report_buy_gold_month
    time = Time.now.beginning_of_year.to_formatted_s :db
    sql = <<-SQL
      SELECT DATE_FORMAT(h.created_at,'%m-%Y') AS MonthOfYear, sum(h.price) as _sum_$ FROM payment_logs h
      where h.kind = #{PaymentLog::BUY_STAFF} and h.created_at > '#{time}' GROUP BY 1 order by MonthOfYear desc;
    SQL
    execute sql
  end

  def report_buy_gold_top_users
    time = 1.month.ago.to_formatted_s :db
    sql = <<-SQL
      select sum(h.price) _sum_$, u.name, p.name partner, SUBSTRING(um.referrer, 1, 30) Ref_url FROM payment_logs h
      join users u on h.user_id = u.id left join user_marketing_infos um on um.user_id = u.id
      left join partners p on p.id = um.partner_id
      where h.kind = #{PaymentLog::BUY_STAFF} and h.created_at > '#{time}'
      group by h.user_id
      order by _sum_$ desc
      limit 100;
    SQL
    execute sql
  end

  def report_disabled_users
    sql = <<-SQL
      select u.id, u.name, u.a_level level, max(b.ban_end_date) ban_end_date, b.public_reason, b.private_reason,
        (select name from users u1 where u1.id = b.banned_by_id) banned_by, b.created_at banned_at
      from users u join ban_histories b on b.user_id = u.id
      where u.active = 0 and u.is_admin = 0
      group by b.user_id
      order by u.updated_at desc
    SQL
    execute sql, :columns => %w(id name level banned_by banned_at ban_end_date public_reason private_reason)
  end

  def report_payment_users_by_level
    t = Time.now.beginning_of_month
    s = t.to_formatted_s :db

    sql = <<-SQL
      select sum(m.value)
      from users u join payment_logs m on u.id = m.user_id
      where h.kind = #{PaymentLog::BUY_STAFF} and m.created_at > '#{s}'
    SQL

    all = select_one sql

    sql = <<-SQL
      select u.a_level level, count(distinct u.id) count, sum(m.value) 'money (this month)', round((sum(m.value)/#{all.to_i})*100,2) "money_r (this month)%"
      from users u join payment_logs m on u.id = m.user_id
      where h.kind = #{PaymentLog::BUY_STAFF} and m.created_at > '#{s}'
      group by u.a_level order by u.a_level
    SQL
    
    execute sql, :columns => ['level', 'count', 'money (this month)', 'money_r (this month)%']
  end

  def report_partner_users_by_level
    partners = Partner.all
    sql_start = "SELECT u.a_level as level, "
    columns = ['level']
    sql = ' from users as u '
    
    partners.each do |partner|
      sql_start << "#{partner.name}, "
      sql     << " left join (select u.a_level as level#{partner.id}, count(distinct u.id) #{partner.name} from users as u left join user_marketing_infos as um on (um.user_id = u.id) where um.partner_id = #{partner.id} group by u.a_level) as p#{partner.id} on (u.a_level = p#{partner.id}.level#{partner.id}) "
      columns << "#{partner.name}"
    end
    sql_start << " 1"
    sql << " group by u.a_level"
    execute sql_start + sql, :columns => columns
  end

  def report_partner_users_by_week_activity
    days = 7

    sql = <<-SQL
      select count(u.id) from users as u where u.last_activity_time >  DATE_ADD(u.created_at, INTERVAL #{days} DAY)
    SQL

    all = select_one sql
    
    partners = Partner.all
    sql = "SELECT "
    columns = []

    partners.each do |partner|
      sql     << "(select concat(count(u.id), ' ( ', round((count(u.id)/#{all.to_i})*100,2), '%)') from user_marketing_infos um left join users as u on (u.id = um.user_id) where um.partner_id = #{partner.id} and u.last_activity_time > DATE_ADD(u.created_at, INTERVAL #{days} DAY)) as '#{partner.name}', "
      columns << "#{partner.name}"
    end

    sql << "1"

    execute sql, :columns => columns
  end

  def report_total_active_users_by_level

    s = GameProperties::USER_HOLIDAY_TIME.ago.to_formatted_s :db

    sql = <<-SQL
      select u.a_level level, count(*) count
      from users u
      where last_activity_time > '#{s}'
      group by a_level order by a_level
    SQL

    execute sql, :columns => ['level', 'count']
  end

  def report_last_spend_money
    sql = <<-SQL
      select u.name, h.reason, h.amount, h.description, h.created_at from payment_logs h
      join users u on u.id = h.user_id
      where kind = '#{PaymentLog::SPEND_STAFF}'
      order by h.id desc limit 50;
    SQL
    execute sql
  end

  def report_last_bonuses
    sql = <<-SQL
      select u.name, h.reason, h.amount, h.description, h.created_at from payment_logs h
      join users u on u.id = h.user_id
      where reason != 'buy_gold' and kind = '#{PaymentLog::ADD_BONUS}'
      order by h.id desc limit 50;
    SQL
    execute sql
  end

  #  def report_biggest_quests
  #    sql = <<-SQL
  #      SELECT count(*) count, sum(u.user_earned) earned, q.owner_id 'owner_id', us.name 'owner_name', q.name 'quest_name', q.finished_at 'quest_finished_at'
  #      FROM quests q join quest_users u on q.id = u.quest_id join users us on q.owner_id = us.id
  #      where q.status in ('f','a') and u.active = 1
  #      group by u.quest_id having earned > 0
  #      order by earned desc limit 20;
  #SQL
  #    execute sql
  #  end

  def report_rawk
    r = `script/rawk -f log/production.log`
    r = CGI.escapeHTML(r)
    "<pre>#{r}</pre>"
  end

  def report_spend_money_all(start = nil, finish = nil)
    
    d = " and kind = #{PaymentLog::SPEND_STAFF}"

    if start
      s = start.to_formatted_s :db
      d += " and created_at > '#{s}' "
    end

    if finish
      f = finish.to_formatted_s :db
      d += " and created_at <= '#{f}'"
    end
    
    sql = <<-SQL
      SELECT
        (SELECT sum(amount) FROM payment_logs where description like 'shop_items.p3%'#{d}) as 'Shop - potion health',
        (SELECT sum(amount) FROM payment_logs where description like 'shop_items.p44%'#{d}) as 'Shop - potion mana',
        (SELECT sum(amount) FROM payment_logs where description like 'shop_time_items.endurance%'#{d}) as 'Shop - endurance',
        (SELECT sum(amount) FROM payment_logs where description like 'shop_time_items.power%'#{d}) as 'Shop - power',
        (SELECT sum(amount) FROM payment_logs where description like 'shop_time_items.safe%'#{d}) as 'Shop - safe',
        (SELECT sum(amount) FROM payment_logs where description like 'shop_time_items.protection%'#{d}) as 'Shop - protection',
        (SELECT sum(amount) FROM payment_logs where description like 'shop_time_items.voodoo%'#{d}) as 'Shop - voodo doll',
        (SELECT sum(amount) FROM payment_logs where description like 'shop_time_items.pet_power%'#{d}) as 'Shop - pet power',
        (SELECT sum(amount) FROM payment_logs where description like 'shop_time_items.antipet%'#{d}) as 'Shop - antipet',
        (SELECT sum(amount) FROM payment_logs where description like 'shop_time_items.pet_antikiller%'#{d}) as 'Shop - pet antikiller',
        (SELECT sum(amount) FROM payment_logs where description like 'shop_items.g%'#{d}) as 'Shop - gifts',
        (SELECT sum(amount) FROM payment_logs where description like 'shop_items.c%'#{d}) as 'Shop - curses',
        (SELECT sum(amount) FROM payment_logs where description like 'item_pet.buy%'#{d}) as 'Pet - buy',
        (SELECT sum(amount) FROM payment_logs where description like 'item_pet.reanimate%'#{d}) as 'Pet - reanimate',
        (SELECT sum(amount) FROM payment_logs where description like 'avatar_items.%'#{d}) as 'Avatars - buy'
    SQL

    execute sql, :vertical => true,
      :columns => ['Shop - potion health', 'Shop - potion mana', 'Shop - endurance', 'Shop - power', 'Shop - safe', 'Shop - protection',
      'Shop - voodo doll', 'Shop - pet power', 'Shop - antipet', 'Shop - pet antikiller', 'Shop - gifts', 'Shop - curses', "Pet - buy", "Pet - reanimate", "Avatars - buy"
    ]
  end

  def report_spend_money_today
    report_spend_money_all Date.today.to_time
  end

  def report_spend_money_yesterday
    report_spend_money_all Date.yesterday.to_time, Date.today.to_time
  end

  def report_spend_money_2_days_ago
    t = Date.yesterday.to_time
    report_spend_money_all (t - 1).beginning_of_day, t
  end

  def report_spend_money_current_week
    t = Time.now.beginning_of_week
    report_spend_money_all t
  end

  def report_spend_money_previous_week
    t = Time.now.beginning_of_week
    report_spend_money_all (t-1).beginning_of_week, t
  end

  def report_spend_money_2_weeks_ago
    t = Time.now.beginning_of_week
    t = (t - 1).beginning_of_week
    report_spend_money_all (t - 1).beginning_of_week, t
  end

  def report_spend_money_current_month
    t = Time.now.beginning_of_month
    report_spend_money_all t
  end

  def report_spend_money_previous_month
    t = Time.now.beginning_of_month
    report_spend_money_all (t-1).beginning_of_month, t
  end

  def report_spend_money_2_months_ago
    t = Time.now.beginning_of_month
    t = (t - 1).beginning_of_month
    report_spend_money_all (t - 1).beginning_of_month, t
  end

  def report_active_users
    sql = <<-SQL
      SELECT
        (select count(*) from users where last_activity_time > "#{Date.today.to_formatted_s(:db)}") as 'Today',
        (select count(*) from users where last_activity_time > "#{Date.yesterday.to_formatted_s(:db)}") as 'Since yesterday',
        (select count(*) from users where last_activity_time > "#{Time.now.beginning_of_week.to_formatted_s(:db)}") as 'This week',
        (select count(*) from users where last_activity_time > "#{Time.now.beginning_of_month.to_formatted_s(:db)}") as 'This month',
        (select count(distinct user_id) from adyen_notifications where success = 1 and live = 1 and created_at > "#{Date.today.to_formatted_s(:db)}") as 'Paid today',
        (select count(distinct user_id) from adyen_notifications where success = 1 and live = 1 and created_at > "#{Date.yesterday.to_formatted_s(:db)}") as 'Paid since yesterday',
        (select count(distinct user_id) from adyen_notifications where success = 1 and live = 1 and created_at > "#{Time.now.beginning_of_week.to_formatted_s(:db)}") as 'Paid this week',
        (select count(distinct user_id) from adyen_notifications where success = 1 and live = 1 and created_at > "#{Time.now.beginning_of_month.to_formatted_s(:db)}") as 'Paid this month'
    SQL

    execute sql, :vertical => true,
      :columns => ['Today', 'Paid today', 'Since yesterday', 'Paid since yesterday', 'This week', 'Paid this week', 'This month', 'Paid this month']
  end

  def report_attributes_by_level
    t = GameProperties::USER_HOLIDAY_TIME.ago.to_formatted_s :db
    sql = <<-SQL
      select a_level level, count(*) count,
        avg(a_weight) avg_weight, avg(a_skill) avg_skill, avg(a_dexterity) avg_dexterity, avg(a_power) avg_power, avg(a_protection) avg_protection,
        max(a_weight) max_weight, max(a_skill) max_skill, max(a_dexterity) max_dexterity, max(a_power) max_power, max(a_protection) max_protection
      from users
      where active = 1 and last_activity_time > '#{t}' and on_holiday = 0
      group by a_level order by a_level desc;
    SQL
    execute sql, :columns => %w(level count avg_power avg_protection avg_skill avg_dexterity avg_weight
      max_power max_protection max_skill max_dexterity max_weight)
  end


  def report_partner_payments
    partners = Partner.all
    sql = "SELECT "
    columns = []

    partners.each do |partner|
      sql     << "(select count(*) from payment_logs p left join user_marketing_infos as um  on (p.user_id = um.user_id) where um.partner_id = #{partner.id} and p.kind = #{PaymentLog::BUY_STAFF}) as '#{partner.name} payments', "
      columns << "#{partner.name} payments"
    end

    sql     << "(select count(*) from payment_logs p where p.kind = #{PaymentLog::BUY_STAFF}) as 'All payments'"
    columns << "All payments"

    execute sql, :vertical => true,
      :columns => columns
  end
  
  #PARTNER REPORTS
  def report_partner_registration_all(start = nil, finish = nil)

    d = " "
    if start
      s = start.to_formatted_s :db
      d += " and um.created_at > '#{s}' "
    end

    if finish
      f = finish.to_formatted_s :db
      d += " and um.created_at <= '#{f}'"
    end
    
    partners = Partner.all
    sql = "SELECT "
    columns = []
    
    partners.each do |partner|
      sql     << "(select count(*) from user_marketing_infos um where um.partner_id = #{partner.id} #{d}) as '#{partner.name} registered', "
      columns << "#{partner.name} registered"

      sql     << "(select count(u.id) from users as u left join user_marketing_infos as um on (um.user_id = u.id) where u.confirmed_email and um.partner_id = #{partner.id} #{d}) as '#{partner.name} confirmed', "
      columns << "#{partner.name} confirmed"

    end

    sql     << "(select count(*) from users um where 1 #{d}) as 'All registered', "
    columns << "All registered"

    sql     << "(select count(*) from users um where um.confirmed_email = true #{d}) as 'All confirmed'"
    columns << "All confirmed"

    execute sql, :vertical => true,
      :columns => columns
  end


  def report_partner_registration_today
    report_partner_registration_all Date.today.to_time
  end

  def report_partner_registration_yesterday
    report_partner_registration_all Date.yesterday.to_time, Date.today.to_time
  end

  def report_partner_registration_2_days_ago
    t = Date.yesterday.to_time
    report_partner_registration_all (t - 1).beginning_of_day, t
  end

  def report_partner_registration_current_week
    t = Time.now.beginning_of_week
    report_partner_registration_all t
  end

  def report_partner_registration_previous_week
    t = Time.now.beginning_of_week
    report_partner_registration_all (t-1).beginning_of_week, t
  end

  def report_partner_registration_2_weeks_ago
    t = Time.now.beginning_of_week
    t = (t - 1).beginning_of_week
    report_partner_registration_all (t - 1).beginning_of_week, t
  end

  def report_partner_registration_current_month
    t = Time.now.beginning_of_month
    report_partner_registration_all t
  end

  def report_partner_registration_previous_month
    t = Time.now.beginning_of_month
    report_partner_registration_all (t-1).beginning_of_month, t
  end

  def report_partner_registration_2_months_ago
    t = Time.now.beginning_of_month
    t = (t - 1).beginning_of_month
    report_partner_registration_all (t - 1).beginning_of_month, t
  end

  #  def report_partner_buy_gold_days
  #    time = Time.now.beginning_of_month.to_formatted_s :db
  #
  #    partners = Partner.all
  #    sql = "SELECT "
  #    columns = []
  #    partners.each do |partner|
  #      sql     << "(SELECT DATE_FORMAT(h.created_at,'%d-%m-%Y') as DayOfMonth, sum(h.value) as _sum_$ FROM adyen_notifications h
  #                  left join user_marketing_infos as um on (um.user_id = h.user_id) where h.success = 1 and h.live = 1 and
  #                  um.partner_id = #{partner.id} and h.created_at > '#{time}' GROUP BY 1 order by DayOfMonth desc) as '#{partner.name}', ##"
  #      columns << "#{partner.name}"
  #
  #    end
  #
  #    sql     << "(select count(*) from users um where 1) as 'All registered' "
  #    columns << "All registered"
  #
  #    execute sql, :vertical => true,
  #      :columns => columns
  #  end

  #  def report_staff2
  #    sql = <<-SQL
  #      SELECT u.id, u.name, c.name clan, u.a_level, u.a_staff2, u.loot_staff2, u.lost_staff2
  #      FROM users u join clans c on c.id = u.clan_id
  #      ORDER BY u.loot_staff2 desc
  #      LIMIT 100
  #SQL
  #    execute sql, :columns => %w(id name clan a_level a_staff2 loot_staff2 lost_staff2)
  #  end

  #  def report_moderator_activity
  #    t = 1.month.ago.to_formatted_s :db
  #    sql = <<-SQL
  #      select id, name, a_level level,
  #        (select count(*) from ban_histories where banned_by_id = u.id and created_at > '#{t}') month_banned_count,
  #        (select count(*) from chat where user_id = u.id and clan_id is null and community_id is null) chat_count
  #      from users u where is_moderator = 1;
  #SQL
  #    execute sql, :columns => %w(id name level month_banned_count chat_count)
  #  end

  private

  def select_all(sql)
    ActiveRecord::Base.connection.select_all(sql)
  end

  def select_one(sql)
    ActiveRecord::Base.connection.select_value(sql)
  end

  def execute(sql, options = {})
    prepare_result select_all(sql), options
  end

  def prepare_result(value, options = {})
    vertical = options[:vertical] || false

    if value.nil? || value.empty?
      return "Nothing"
    end
    r = "<table border=\"1\">"

    columns = options[:columns] ? options[:columns] : value[0].keys

    if !vertical
      r += "<tr>"
      columns.each do |k|
        r += "<th>#{k}</th>"
      end
      r += "</tr>"
      value.each do |v|
        r += "<tr>"
        columns.each do |c|
          vv = v[c]
          r += "<td>#{vv}</td>"
        end
        r += "</tr>"
      end
    else
      columns.each do |k|
        r += "<tr>"
        r += "<td><strong>#{k}<strong></td>"
        value.each do |v|
          r += "<td>#{v[k]}</td>"
        end
        r += "</tr>"
      end
    end

    r += "</table>"
    r
  end

end

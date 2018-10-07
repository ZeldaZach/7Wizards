# TODO is not tested, need to test and include into schedulers. we should run it once a day. the same as on wekings ...

class Schedule::ReferenceBonus < Schedule::Base

  def self.distribute(time = Time.now.yesterday)

    sql = <<-SQL
      SELECT n.user_id, sum(n.amount) as staff, u.referral_id, u.name user_name
      FROM payment_logs n JOIN users u on n.user_id = u.id
      WHERE n.kind = ? and n.created_at >= ? and n.created_at <= ? and u.referral_id is not null
      GROUP BY n.user_id
      HAVING staff >= ?
    SQL

    start = time.beginning_of_day
    finish = time.end_of_day
    items = PaymentLog.find_by_sql [sql, PaymentLog::BUY_STAFF, start, finish, (100 / GameProperties::REFERENCE_BONUS_PAYMENTS_PERCENT).to_i]

    # we should group all bonuses by users
    all_users = {}
    items.each do |item|
      user = item.referral_id.to_i
      bonuses = all_users[user] || { :total => 0, :items => [] }
      bonuses[:items] << item
      bonuses[:total] += item.staff.to_i
      all_users[user] = bonuses
    end

    # and now we can distribute bonuses
    all_users.each_pair do |referral_id, bonuses|
      bonus = 0
      message = ''
      bonuses[:items].each do |item|
        user_bonus = (item.staff.to_i * GameProperties::REFERENCE_BONUS_PAYMENTS_PERCENT.to_percent).to_i
        if user_bonus > 0
          message += Message.t :reference_bonus_user, :name => item.user_name, :staff => User.tps(user_bonus)
          bonus += user_bonus
        end
      end
      if bonus > 0
        title = Message.t :reference_bonus_title, :staff => User.tps(bonus)
        message = Message.t :reference_bonus, :message => message, :staff => User.tps(bonus)

        user = User.find referral_id
        user.transaction do
          user.add_staff(bonus, "reference_bonus", message)
          if user.save
            Message.send_admin_message user, message, title
          else
            Notifier.deliver_error "reference bonus distribution problem, user: #{user.id}, date: #{time}", message
          end
        end
      end
    end
  end

  self.redefine(self)
end

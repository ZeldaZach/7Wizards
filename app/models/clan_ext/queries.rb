module ClanExt
  module Queries

    BEST_ORDER = "all_reputation DESC, all_wins DESC"
    
    def calculate_rating
      sql = <<-SQL
        SELECT rownum, id FROM
        (
          SELECT @rownum:=@rownum+1 rownum, t.* FROM (SELECT @rownum:=0) rows,
          (
            SELECT c.id, SUM(u.a_reputation) as all_reputation, SUM(c.s_wins_count) as all_wins, SUM(u.a_money) as all_money, SUM(u.a_staff) as all_staff
            FROM users u join clans c on u.clan_id = c.id
            WHERE u.active = true and c.active = true
            GROUP BY u.clan_id
            ORDER BY all_reputation DESC, all_wins DESC, all_staff DESC, all_money DESC
          ) t
        ) r
        WHERE r.id = #{self.id}
      SQL

      self.select_value( sql )
    end

    def get_active_users_power
      conditions = User.apply_active_conditions ['clan_id = ?', self.id]
      User.sum :a_power, :conditions => conditions
    end

    def get_users_protection
      User.sum :a_protection, :conditions => [ 'clan_id = ?', self.id ]
    end

    def self.included(klass)
      klass.extend ClassMethods
    end

    module ClassMethods

      def find_the_best_clans(filter = {}, order = Clan::BEST_ORDER, page = 1, total_count = 1, perpage = per_page)

        where = "u.active = ? and c.active = ? "
        conditions = [true, true]

        if !filter[:owner_name].blank?
          where      << " and u.name like ?"
          conditions << "%#{filter[:owner_name]}%"
        elsif !filter[:clan_name].blank?
          where      << " and c.name like ?"
          conditions << "%#{filter[:clan_name]}%"
        end

        sql = <<-SQL
          SELECT c.*, SUM(u.a_reputation) as all_reputation, SUM(c.s_wins_count) as all_wins, SUM(u.a_money) as all_money, SUM(u.a_staff) as all_staff
          FROM users u join clans c on u.clan_id = c.id 
          WHERE #{where}
          GROUP BY u.clan_id
          ORDER BY #{order}
        SQL

        page = page ? page.to_i : 1

        r = paginate_by_sql [sql, *conditions], :page => page, :per_page => perpage, :total_entries => total_count

        rating = perpage * (page - 1) + 1
        r.each do |clan|
          clan.rating = rating
          rating += 1
        end
      end

      def find_the_best
        result = find_the_best_clans
        result.blank? ? nil : result[0]
      end

    end
  end
end

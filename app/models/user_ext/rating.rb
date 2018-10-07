module UserExt
  module Rating

    BEST_ORDER = "a_reputation DESC, s_wins_count DESC"

    def calculate_rating
        sql = <<-SQL
          SELECT count(*) FROM users
          WHERE a_reputation > (SELECT a_reputation FROM users WHERE id = #{self.id})
        SQL
        self.connection.select_value( sql )
      end

    def rating
      if !defined?(@rating) || !@rating
        @rating = calculate_rating 
      end
      @rating.to_i + 1
    end

    def rating=(value)
      @rating = value
    end

    def self.included(klass)
      klass.extend ClassMethods
    end

    module ClassMethods

      # the same as find_by_name
      def f(name)
        find_by_name_and_deleted name, false
      end

      def find_the_best_users(filter = {}, order = User::BEST_ORDER, page = 1, total_count = 10, perpage = per_page)
        filter[:name] ||= ""
        
        page = page ? page.to_i : 1
        order = order ? order : User::BEST_ORDER
        
        conditions_base = "name like ? and confirmed_email"
        conditions = [conditions_base, "%#{filter[:name]}%"]

        unless filter[:gender].blank?
          conditions[0] += " and gender = ?"
          conditions << filter[:gender]
        end

        if filter[:online]
          conditions[0] += " and last_activity_time > ?"
          conditions << GameProperties::USER_ACTIVE_PERIOD.ago
        end

        User.active.paginate(
          :conditions => conditions,
          :order => order,
          :page => page,
          :per_page => perpage,
          :total_entries => total_count)

#        rating = per_page * (page - 1) + 1
#        r.each do |user|
#          user.rating = rating
#          rating += 1
#        end
      end

      def find_the_best_top10
        User.active.all :order => User::BEST_ORDER, :limit => 10
      end

      def find_the_best
        result = find_the_best_users
        result.blank? ? nil : result[0]
      end

      def find_top_voting(page = 1, total_count = 10, perpage = per_page)
        User.active.paginate(
          :conditions => ["confirmed_email and s_vote > ?", 0],
          :order => "s_vote DESC, a_reputation DESC",
          :page => page,
          :per_page => perpage,
          :total_entries => total_count
          )
      end

    end
  end
end

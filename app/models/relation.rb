class Relation < ActiveRecord::Base

  # include base mode behaviour
  include BaseModel

  belongs_to :user
  belongs_to :relative, :class_name => 'User', :foreign_key => 'relative_id'
  
  default_scope :order => 'id desc'

  KIND_ROB = 'r'
  KIND_VENGENCE = 'v'
  KIND_FRIEND = 'f'
  KIND_IGNORE = 'i'
  KIND_BOOKMARK = 'b'
  KIND_UNKNOWN = 'n'
  ALL_KINDS = [KIND_ROB, KIND_VENGENCE, KIND_FRIEND, KIND_IGNORE, KIND_BOOKMARK]

  def before_save
    self.kind ||= KIND_UNKNOWN
  end

  def is_friend?
    kind == KIND_FRIEND
  end

  def is_flagged?
    kind == KIND_BOOKMARK
  end

  def self.paginate_by_kind_and_user(kind, user, options = {})
    options[:per_page] ||= per_page
    options = options.dup
    self.add_conditions options, ["#{self.table_name.downcase}.active = ? and user_id = ? and kind = ?", true, user, kind]
    self.paginate options
  end

  def self.count_by_kind_and_user(kind, user)
    self.count :conditions => ['active = ? and user_id = ? and kind = ?', true, user, kind]
  end

  def self.paginate_friend_requests(user, options = {})
    options[:per_page] ||= per_page
    options = options.dup
    self.add_conditions options, ["#{self.table_name.downcase}.active = ? and relative_id = ? and kind = ?", false, user, KIND_FRIEND]
    self.paginate options
  end

  def self.count_friend_requests(user)
    self.count :conditions => ['active = ? and relative_id = ? and kind = ?', false, user, KIND_FRIEND]
  end

  def self.count_relation(user1, user2, kind)
    sql=<<-SQL
      SELECT COUNT(*) FROM relations where (user_id = #{user1.id} and relative_id = #{user2.id} )
      OR (user_id = #{user2.id} AND relative_id = #{user1.id}) AND kind = '#{kind}'
    SQL
    count_by_sql(sql)
  end

  def self.has_active_relation?(user, relative, kind = nil)
    r = get_relation(user, relative, kind)
    return false if !r || !r.active
    kind ? r.kind == kind : true
  end

  def self.has_relation?(user, relative, kind)
    !get_relation(user, relative, kind).nil?
  end

  def self.get_relation(user, relative, kind = nil)
    conditions = { :user_id => user.id, :relative_id => relative.id}
    conditions[:kind] = kind unless kind.nil?
    self.find :first, :conditions => conditions
  end

  def self.destroy_all_relations(user, relative, kind)
    self.destroy_all :user_id => user.id, :relative_id => relative.id, :kind => kind
    if kind == Relation::KIND_FRIEND
      self.destroy_all :user_id => relative.id, :relative_id => user.id, :kind => kind
    end
  end

  def self.get_friend_request(user, relative)
    Relation.first :conditions => { :user_id => user.id, :relative_id => relative.id,
        :kind => Relation::KIND_FRIEND, :active => false }
  end

end 
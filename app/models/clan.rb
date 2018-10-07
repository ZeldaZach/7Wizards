class Clan < ActiveRecord::Base

  require 'ar-deltas'

  # include base mode behaviour
  include BaseModel
  include Ext::StatModel
  include Ext::Validators

  include ClanExt::Params
  include ClanExt::Stats
  include ClanExt::Queries
  include ClanExt::War
  include ClanExt::Union
  include ClanExt::Payment

  # all validators
  validates_uniqueness_of :name
  validates_presence_of :name
  validates_size_of :name, :within => 3..15
  validates_size_of :description, :within => 0..200, :allow_nil => true
  validates_format_of :name, :with => /^[\w 0-9]+$/i

  # all relationships
  has_many :users
  belongs_to :creator, :class_name => 'User', :foreign_key => 'creator_id'
  belongs_to :owner, :class_name => 'User', :foreign_key => 'owner_id'
  
  named_scope :active, :conditions => ['active = ?', true]

  serialize :stats

  delta_attributes :a_money, :a_staff2

  def register
    self.a_money = GameProperties::CLAN_INITIAL_MONEY
    self.a_staff2 = GameProperties::CLAN_INITIAL_STAFF2
    save
  end
  
end

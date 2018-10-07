class DragonUser < ActiveRecord::Base

  require 'ar-deltas'

  include BaseModel

  belongs_to :user
  belongs_to :dragon

  delta_attributes :received_money
  delta_attributes :received_staff2
  delta_attributes :attacks_count

end

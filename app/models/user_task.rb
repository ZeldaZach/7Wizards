class UserTask < ActiveRecord::Base
  
  # include base mode behavior
  include BaseModel
  
  belongs_to :user

  named_scope :task_name, lambda  { |name| { :conditions => {:name => name }} }
  named_scope :order_by_id, lambda  { { :order => "id" } }
end

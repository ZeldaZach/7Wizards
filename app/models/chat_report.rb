class ChatReport < ActiveRecord::Base

  belongs_to :user
  belongs_to :reporter, :class_name => 'User', :foreign_key => 'reporter_id'

  def self.last_reports
    
  end
end

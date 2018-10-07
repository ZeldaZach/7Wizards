class ChatMessage < BaseOhmModel
  
  HISTORY_LIMIT = 40
  EXPIRE_TIME = 1.days

  time_stamps

  attribute_ref :user
  attribute :message
  attribute :chat_room

  index_ref :user
  index :chat_room

  def validate
    assert_present_ref :user
    assert_present :chat_room
  end

  #override
  def expire_time
    EXPIRE_TIME
  end

  def self.last_messages(room)
    find({:chat_room => room}).sort_by(:created_at, :order => "DESC", :limit => HISTORY_LIMIT)
  end

  def self.last_user_messages(user)
    find({:user => user}).sort_by(:created_at, :order => "DESC", :limit => 3)
  end

end

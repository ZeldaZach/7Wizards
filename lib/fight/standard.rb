class Fight::Standard < Fight::Base

  def initialize(user, opponent)
    @user = user
    @user_a = @user.user_attributes( :fight_user => true ) unless @user_a
    @opponent = opponent
    @opponent_a = @opponent.user_attributes( :fight_opponent => true ) unless @opponent_a
    
    super()
  end

end
class AvatarVoting < ActiveRecord::Base
  belongs_to :user
  belongs_to :user_avatar, :class_name => 'UserAvatar', :foreign_key => 'user_avatar_id'
  belongs_to :voter, :class_name => 'User', :foreign_key => 'voter_id'


  class << self
    
    def vote!(voter, user)
      avatar_voting = AvatarVoting.new
      avatar_voting.user = user
      avatar_voting.voter = voter
      avatar_voting.user_avatar = user.active_avatar

      user.s_vote += 1
    
      user.transaction do
        avatar_voting.save!
        user.save!
      end
    end

    def votes_count(user)
      AvatarVoting.count :conditions => {:user_id => user.id}
    end
    
    def can_vote?(voter, user)
      self.voter_today_count(voter) < GameProperties::AVATAR_VOTING_PER_DAY_MAX && self.voter_user_today_count(voter, user) == 0 &&
        voter.a_level >= GameProperties::AVATAR_VOTING_MIN_LEVEL
    end

    def voter_user_today_count(voter, user)
      AvatarVoting.count :conditions => ["voter_id = ? and user_id = ? and created_at > ?", voter.id, user.id, Time.now.beginning_of_day]
    end

    def voter_today_count(voter)
       AvatarVoting.count :conditions => ["voter_id = ? and created_at > ?", voter.id, Time.now.beginning_of_day]
    end
    
  end

end

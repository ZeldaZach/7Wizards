class CreateAvatarVotings < ActiveRecord::Migration
  def self.up
    create_table :avatar_votings do |t|
      t.integer  "user_id",         :null => false
      t.integer  "user_avatar_id",  :null => false
      t.integer  "voter_id",         :null => false
      t.timestamps
    end

    add_column :users, :s_vote, :integer, :default => 0
  end

  def self.down
    drop_table :avatar_votings
  end
end

class AddAttackerMessage < ActiveRecord::Migration
  def self.up
    User.update_all(:attacker_message => "How dare you to challenge me ??? Ugh!")
  end

  def self.down
  end
end

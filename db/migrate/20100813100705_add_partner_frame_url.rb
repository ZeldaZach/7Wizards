class AddPartnerFrameUrl < ActiveRecord::Migration
  def self.up
    add_column :partners, :frame_url, :string
  end

  def self.down
    remove_column :partners, :frame_url
  end
end

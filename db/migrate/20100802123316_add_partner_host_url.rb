class AddPartnerHostUrl < ActiveRecord::Migration
  def self.up
    add_column :partners, :host_url, :string
  end

  def self.down
    remove_column :partners, :host_url
  end
end

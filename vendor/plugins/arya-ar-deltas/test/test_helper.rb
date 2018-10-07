TEST_DIR = File.dirname(__FILE__)
%w(lib test).each do |dir|
  $LOAD_PATH.unshift File.join(TEST_DIR, "..", dir)
end

require 'test/unit'
require 'rubygems'
require 'shoulda'

require 'activerecord'
require 'ar-deltas'

# To run the tests, you need a MySQL database as described below.
# create table widgets (id int auto_increment primary key, counter int default 0, name varchar(255));

module TestHelper
  def connection_specification
    {:username => "root", :password => "", :database => "ar_deltas", :adapter => "mysql"}
  end
end
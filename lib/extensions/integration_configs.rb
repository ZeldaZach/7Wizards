require 'yaml'
require 'ostruct'
require 'right_aws'

::S3Config = OpenStruct.new(YAML.load_file(File.join(RAILS_ROOT, 'config', 'amazon_s3.yml')))

::BigpointConfig = OpenStruct.new(YAML.load_file(File.join(RAILS_ROOT, 'config', 'bigpoint.yml'))[RAILS_ENV])

::FacebookConfig = OpenStruct.new(YAML.load_file(File.join(RAILS_ROOT, 'config', 'facebook.yml')))




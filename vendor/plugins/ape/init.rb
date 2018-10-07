require 'yaml'
require 'ostruct'

::ApeConfig = OpenStruct.new(YAML.load_file(File.join(RAILS_ROOT, 'config', 'ape.yml'))[RAILS_ENV])

Ape.set_defaults
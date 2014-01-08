require 'rspec'
require 'rspec/autorun' # needed for rspec 2.6.x
require 'yajl'
require 'jiraby'

TEST_DIR = File.dirname(__FILE__)
DATA_DIR = File.join(TEST_DIR, 'data')

def json_data(json_filename)
  data = File.read(File.join(DATA_DIR, json_filename))
  return Yajl::Parser.parse(data)
end

RSpec.configure do |config|
  config.include Jiraby
end


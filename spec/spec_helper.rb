require 'rspec'
require 'rspec/autorun' # needed for rspec 2.6.x
require 'jiraby'

RSpec.configure do |config|
  config.include Jiraby
end


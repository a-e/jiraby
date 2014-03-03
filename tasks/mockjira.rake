require 'rake'
require 'rakeup'

RakeUp::ServerTask.new('mockjira') do |t|
  t.port = 9292
  t.pid_file = 'mockjira.pid'
  t.rackup_file = 'spec/mockapp/config.ru'
  t.server = :thin
end


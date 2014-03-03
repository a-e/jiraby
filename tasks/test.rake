require 'rake'

desc "Start test server, run all tests, then stop test server"
task :test do |t|
  Rake::Task["mockjira:autostart"].invoke
  Rake::Task["spec"].invoke
  Rake::Task["mockjira:autostop"].invoke
end

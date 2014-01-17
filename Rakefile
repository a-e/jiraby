require 'rake'
require 'rspec/core/rake_task'

desc "Run spec tests"
RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = 'spec/**/*_spec.rb'
    t.rspec_opts = ['--color', '--format doc']
end

desc "Start a pry session with the given Jira host"
task :pry, [:jira_host] do |t, args|
  require 'pry'
  require 'jiraby'
  if !args.jira_host
    puts "Usage: rake pry[jira.host.url]"
  else
    jira_url = "http://#{args.jira_host}"
    puts "Connecting to Jira at #{jira_url}"
    jira = Jiraby::Jira.new(jira_url)
    binding.pry
  end
end


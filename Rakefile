require 'rake'
require 'rspec/core/rake_task'

desc "Run spec tests"
RSpec::Core::RakeTask.new(:spec) do |t|
    t.pattern = 'spec/**/*_spec.rb'
      t.rspec_opts = ['--color', '--format doc']
end

desc "Run spec tests and measure coverage"
RSpec::Core::RakeTask.new(:rcov) do |t|
  t.pattern = 'spec/**/*_spec.rb'
  t.rspec_opts = ['--color', '--format doc']
  t.rcov = true
  t.rcov_opts = [
    '--exclude /.gem/,/gems,spec',
    '--include-file lib/**/*.rb',
  ]
end

task :pry, [:jira_url] do |t, args|
  require 'pry'
  require 'jiraby'
  if !args.jira_url
    puts "Usage: rake pry[jira.host.url]"
  else
    jira_url = "http://#{args.jira_url}"
    puts "Connecting to Jira at #{jira_url}"
    jira = Jiraby::Jira.new(jira_url)
    binding.pry
  end
end


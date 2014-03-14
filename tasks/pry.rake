require 'rake'

default_host = "localhost:8080"

desc "Start a pry session with the given Jira host (default #{default_host})"
task :pry, [:jira_host] do |t, args|
  require 'pry'
  require 'jiraby'
  if !args.jira_host
    puts "No hostname given; using #{default_host}"
    jira_host = default_host
  else
    jira_host = args.jira_host
  end
  jira_url = "http://#{jira_host}"
  puts "Connecting to Jira at #{jira_url}"
  jira = Jiraby::Jira.new(jira_url)
  binding.pry
end


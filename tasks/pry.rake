require 'rake'

desc "Pry session with the given Jira configuration file (YAML)"
task :pry, :config_yml do |t, args|
  if !args.config_yml
    puts "Usage: rake pry[config.yml]"
    puts "Where config.yml looks something like:"
    puts "  url: 'jira.enterprise.com'"
    puts "  username: 'picard'"
    puts "  password: 'earlgrey'"
    exit
  end

  require 'pry'
  require 'jiraby'
  require 'yaml'

  config = YAML.load(File.open(args.config_yml))

  jira = Jiraby::Jira.new(
    config['url'],
    config['username'],
    config['password']
  )

  binding.pry
end


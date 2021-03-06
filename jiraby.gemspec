Gem::Specification.new do |s|
  s.name = "jiraby"
  s.version = "0.0.2"
  s.summary = "Jira-Ruby bridge"
  s.description = <<-EOS
    Jiraby is a Ruby wrapper for the JIRA REST API,
    supporting Jira 6.x.
  EOS
  s.authors = ["Eric Pierce"]
  s.email = "wapcaplet88@gmail.com"
  s.homepage = "http://github.com/a-e/jiraby"
  s.platform = Gem::Platform::RUBY

  s.add_dependency 'rest-client'
  s.add_dependency 'yajl-ruby'
  s.add_dependency 'hashie'

  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'sinatra'
  s.add_development_dependency 'rakeup'
  s.add_development_dependency 'thin'
  s.add_development_dependency 'yard'
  s.add_development_dependency 'redcarpet'

  s.files = `git ls-files`.split("\n")
  s.require_path = 'lib'
end


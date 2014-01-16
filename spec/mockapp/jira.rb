#!/usr/bin/env ruby
# Mock Jira API sinatra app

require 'sinatra/base'
require 'erb'
require 'yajl'

class MockJira < Sinatra::Base
  set :root, File.dirname(__FILE__)
  set :static, false

  before do
    content_type :json
  end

  get '/' do
    "Hello!"
  end

  post '/rest/auth/1/session' do
    data = Yajl::Parser.parse(request.body.read)
    if data['username'] == 'user' and data['password'] == 'password'
      erb :"auth/login_success"
    else
      halt 401, erb(:"auth/login_failed")
    end
  end

  get '/rest/auth/1/session' do
  end

  delete '/rest/auth/1/session' do
    erb :"auth/logout_success"
  end

  post '/rest/api/2/search' do
    erb :search
  end

  post '/rest/api/2/issue' do
    erb :"issue/TST-1"
  end

  get '/rest/api/2/field' do
    erb :field
  end

  get '/rest/api/2/:resource/:action' do |resource, action|
    begin
      erb :"#{resource}/#{action}"
    rescue
      erb :"#{resource}/err_nonexistent", :locals => {:key => action}
    end
  end

  get '/rest/api/2/*' do
    subpath = params[:splat]
    return "You requested '#{subpath}'"
  end
end # class MockJira


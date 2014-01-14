require_relative 'spec_helper'
require 'jiraby/rest'
require 'jiraby/resource_api'

describe Jiraby::ResourceAPI do
  before(:each) do
    @rest = Jiraby::Rest.new('http://example.com/rest/api/2')
    todo_stub = RuntimeError.new("RestClient call needs a stub")
    RestClient.stub(:get).and_raise(todo_stub)
    RestClient.stub(:post).and_raise(todo_stub)
  end

  describe "#initialize" do
    it "TODO"
  end #initialize

  describe "#get" do
    before(:each) do
    end

    it "GET /<name>" do
      api = Jiraby::ResourceAPI.new(@rest, 'project')
      @rest.should_receive(:get).with('project')
      api.get
    end

    it "GET /<name>/<subpath>" do
      api = Jiraby::ResourceAPI.new(@rest, 'issue')
      @rest.should_receive(:get).with('issue/TST-1')
      api.get('TST-1')

      @rest.should_receive(:get).with('issue/createmeta')
      api.get('createmeta')
    end

    it "GET /<name>/<subpath>/<method>" do
      api = Jiraby::ResourceAPI.new(@rest, 'issue')
      @rest.should_receive(:get).with('issue/TST-1/worklog')
      api.get('TST-1', 'worklog')
      @rest.should_receive(:get).with('issue/TST-1/editmeta')
      api.get('TST-1', 'editmeta')
    end

    it "returns a Resource of JSON data" do
      api = Jiraby::ResourceAPI.new(@rest, 'issue')
      issue_json = {'key' => 'TST-1'}
      @rest.stub(:get).with('issue/TST-1').and_return(issue_json)
      issue = api.get('TST-1')
      issue.should be_a(Jiraby::Resource)
      issue.should == issue_json
    end
  end #get

  describe "#post" do
    before(:each) do
      @issue_api = Jiraby::ResourceAPI.new(@rest, 'issue')
      @issue_data = {
        "fields" => {
          "project" => { "id" => "10000" },
          "issuetype" => { "id" => "10000" },
        }
      }
    end

    it "POST <name>" do
      @rest.should_receive(:post).with('issue', @issue_data)
      @issue_api.post @issue_data # Create a new issue: POST /issue
    end

    it "POST <name>/<subpath>"
    it "POST <name>/<subpath>/<method>"

    it "returns a Resource of JSON data" do
      @rest.stub(:post).with('issue', @issue_data).and_return(@issue_data)
      issue = @issue_api.post @issue_data
      issue.should be_a(Jiraby::Resource)
      issue.should == @issue_data
    end
  end #post

end # Jiraby::Resource


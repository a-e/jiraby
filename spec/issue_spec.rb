require_relative 'spec_helper'
require_relative 'data/jira_issues'

describe Jiraby::Issue do
  before(:each) do
    @issue = Jiraby::Issue.new(json_data('issue_10002.json'))
  end

  describe '#initialize' do
    it "accepts a JSON hash structure" do
      json = json_data('issue_10002.json')
      issue = Jiraby::Issue.new(json)
      issue.should == json
    end
  end

  describe '#key' do
    it "passes through to Hash#key if arguments are included" do
      @issue.key('10002').should == 'id'
      @issue.key('TST-1').should == 'key'
    end

    it "returns the value in the issue's `key` field" do
      @issue.key.should == 'TST-1'
    end
  end
end


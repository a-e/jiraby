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
end


require_relative 'spec_helper'
require_relative 'data/jira_issues'

describe Jiraby::Issue do
  before(:each) do
    @issue = Jiraby::Issue.new(json_data('issue_10002.json'))
  end

  describe '#initialize' do
    it "accepts a JSON hash structure" do
      json = {
        'key' => 'TST-1',
        'fields' => {
          'status' => 'New',
          'assignee' => 'Eric Pierce',
        },
      }
      issue = Jiraby::Issue.new(json)
      issue.json.should == json
    end
  end

  describe '#key' do
    it "returns the unique issue key" do
      @issue.key.should == 'TST-1'
    end
  end

  describe '#fields' do
    it "returns all field names in the issue" do
      expect_fields = [
        'attachment', 'comment', 'description', 'issuelinks', 'project',
        'sub-tasks', 'timetracking', 'updated', 'watcher', 'worklog',
      ]
      @issue.fields.sort.should == expect_fields.sort
    end
  end

  describe '#field_value' do
    it "returns the value in the given field" do
      @issue.field_value('description').should == "example bug report"
    end
  end #field_value

  describe '#method_missing' do
    it "returns a value from a field attribute" do
      @issue.description.should == "example bug report"
    end

    it "raises an exception for unknown field attribute" do
      lambda do
        @issue.bogus
      end.should raise_error(NoMethodError)
    end
  end #method_missing
end


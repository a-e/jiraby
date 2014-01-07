require_relative 'spec_helper'
require_relative 'data/jira_issues'

describe Jiraby::Issue do
  before(:each) do
    @json = {
      'key' => 'TST-1',
      'fields' => {
        'status' => 'New',
        'assignee' => 'Eric Pierce',
      },
    }
    @issue = Jiraby::Issue.new(@json)
  end

  describe '#initialize' do
    it "accepts a JSON hash structure" do
      @issue.json.should == @json
    end
  end

  describe '#key' do
    it "returns the unique issue key" do
      @issue.key.should == 'TST-1'
    end
  end

  describe '#fields' do
    it "returns all field names in the issue" do
      @issue.fields.should == ['assignee', 'status']
    end
  end

  describe '#field_value' do
  end

  describe '#field_name' do
  end

  context 'API 2.0.alpha1' do
    before(:each) do
      @issue = Jiraby::Issue.new(JIRA_2_ALPHA_ISSUE)
    end

    describe '#field_value' do
      it "returns the value in the given field" do
        @issue.field_value('summary').should == "New widget"
        @issue.field_value('description').should == "We need a new foo widget"
        @issue.field_value('comment').should == []
      end
    end

    describe '#method_missing' do
      it "returns a value from a field attribute" do
        @issue.summary.should == "New widget"
        @issue.description.should == "We need a new foo widget"
        @issue.comment.should == []
      end

      it "raises an exception for unknown field attribute" do
        lambda do
          @issue.bogus
        end.should raise_error(NoMethodError)
      end
    end
  end # API 2.0.alpha1

  context 'API 2' do
    before(:each) do
      @issue = Jiraby::Issue.new(JIRA_2_ISSUE)
    end

    describe '#field_value' do
      it "returns the value in the given field" do
        @issue.field_value('summary').should == "New widget"
        @issue.field_value('description').should == "We need a new foo widget"
        @issue.field_value('comment').should == {
          "comments" => [], "startAt" => 0, "total" => 0, "maxResults" => 0}
      end
    end

    describe '#method_missing' do
      it "returns a value from a field attribute" do
        @issue.summary.should == "New widget"
        @issue.description.should == "We need a new foo widget"
        @issue.comment.should == {
          "comments" => [], "startAt" => 0, "total" => 0, "maxResults" => 0}
      end

      it "raises an exception for unknown field attribute" do
        lambda do
          @issue.bogus
        end.should raise_error(NoMethodError)
      end
    end
  end # API 2

end


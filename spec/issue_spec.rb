require_relative 'spec_helper'
require_relative 'data/jira_issues'

describe Jiraby::Issue do
  before(:each) do
    @jira = Jiraby::Jira.new('jira.example.com')
    @jira.stub(:field_mapping => {})
    @issue = Jiraby::Issue.new(@jira, json_data('issue_10002.json'))
  end

  context "Class methods" do
  end # Class methods

  context "Instance methods" do
    describe '#initialize' do
      it "accepts a JSON hash structure" do
        json = json_data('issue_10002.json')
        issue = Jiraby::Issue.new(@jira, json)
        issue.data.should == json
      end
    end

    describe "#[]" do
      it "accepts field `id`" do
        @issue['description'].should == "example bug report"
      end

      it "accepts field `name`"

      it "returns the value set by `#[]=`" do
        @issue['description'] = "Foobar"
        @issue['description'].should == "Foobar"
      end

      it "raises an exception on invalid field name"
    end

    describe "#[]=" do
      it "accepts field `id`" do
        @issue['description'] = "Foobar"
        @issue.updates['description'].should == "Foobar"
      end

      it "accepts field `name`"
      it "raises an exception on invalid field name"
    end

    describe "#field_id" do
      before(:each) do
        @ids_and_names = {
          'description' => 'Description',
          'sub-tasks' => 'Sub-Tasks',
          'project' => 'Project',
        }
        @jira.stub(:field_mapping => @ids_and_names)
      end

      it "returns ID as-is" do
        @ids_and_names.keys.each do |id|
          @issue.field_id(id).should == id
        end
      end

      it "returns the ID for a given name" do
        @ids_and_names.each do |id, name|
          @issue.field_id(name).should == id
        end
      end

      it "raises an exception when invalid name or ID is given" do
        lambda do
          @issue.field_id("Completely Bogus")
        end.should raise_error(/Invalid field name or ID/)
      end
    end

    describe "#key" do
      it "returns nil if the key is undefined" do
        issue = Jiraby::Issue.new(@jira, {})
        issue.key.should be_nil
      end

      it "returns the key field from the issue's data" do
        @issue.key.should == @issue.data['key']
      end
    end

    describe "#editmeta" do
      it "requests editmeta for the current issue" do
        @jira.should_receive(:get).
          with("issue/#{@issue.key}/editmeta").
          and_return({})
        @issue.editmeta
      end
    end

    describe "#modified?" do
      it "returns true if updates are pending" do
        @issue["description"] = "Foo"
        @issue.modified?.should be_true
      end

      it "returns false if no updates are pending" do
        @issue.modified?.should be_false
      end
    end

    describe "#save" do
      it "sends a PUT request to Jira with updates" do
        @issue['description'] = "Modified description"
        expect_fields = {
          'fields' => @issue.updates
        }
        @jira.should_receive(:put).
          with("issue/#{@issue.key}", expect_fields)
        @issue.save
      end

      it "resets modified status" do
        @jira.stub(:put => nil)
        @issue['description'] = "Modified description"
        @issue.modified?.should be_true
        @issue.save
        @issue.modified?.should be_false
      end
    end

  end # Instance methods"
end


require_relative 'spec_helper'
require_relative 'data/jira_issues'

describe Jiraby::Issue do
  before(:each) do
    @field_mapping = {
      'description' => 'Description',
      'customfield_10001' => 'Custom Field',
    }
    @jira = Jiraby::Jira.new('jira.example.com', 'username', 'password')
    @jira.stub(:field_mapping => @field_mapping)
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

      it "accepts field `name`" do
        @issue['Custom Field'].should == "custom field value"
      end

      it "returns the value set by `#[]=`" do
        @issue['description'] = "Foobar"
        @issue['description'].should == "Foobar"
      end

      it "raises an exception on invalid field name" do
        lambda do
          @issue['bogus']
        end.should raise_error(
          Jiraby::InvalidField, /Invalid field name or ID: bogus/)
      end
    end

    describe "#[]=" do
      it "accepts field `id`" do
        @issue['description'] = "Foobar"
        @issue.pending_changes['description'].should == "Foobar"
      end

      it "accepts field `name`" do
        @issue['Custom Field'] = "Modified"
        @issue.pending_changes[@field_mapping.key('Custom Field')].should == "Modified"
      end

      it "raises an exception on invalid field name" do
        lambda do
          @issue['bogus'] = "Modified"
        end.should raise_error(
          Jiraby::InvalidField, /Invalid field name or ID: bogus/)
      end
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

    describe "#pending_changes?" do
      it "returns true if updates are pending" do
        @issue["description"] = "Foo"
        @issue.pending_changes?.should be_true
      end

      it "returns false if no updates are pending" do
        @issue.pending_changes?.should be_false
      end
    end

    describe "#save!" do
      it "sends a PUT request to Jira with updates" do
        @issue['description'] = "Modified description"
        expect_fields = {
          'fields' => @issue.pending_changes
        }
        @jira.should_receive(:put).
          with("issue/#{@issue.key}", expect_fields)
        @issue.save!
      end

      it "updates the data attribute with the new changes" do
        @jira.stub(:put)
        original_description = @issue['description']
        modified_description = "Modified description"

        @issue.data.fields.description.should == original_description
        @issue['description'] = modified_description
        @issue.save!
        @issue.data.fields.description.should == modified_description
      end

      it "resets pending_changes" do
        @jira.stub(:put => nil)
        @issue['description'] = "Modified description"
        @issue.pending_changes.should_not be_empty
        @issue.pending_changes?.should be_true
        @issue.save!
        @issue.pending_changes.should be_empty
        @issue.pending_changes?.should be_false
      end
    end

    describe "#has_field?" do
      before(:each) do
        @ids_and_names = {
          'description' => 'Description',
          'sub-tasks' => 'Sub-Tasks',
          'project' => 'Project',
        }
        @jira.stub(:field_mapping => @ids_and_names)
      end

      it "true when issue has a field with the given ID" do
        @ids_and_names.keys.each do |id|
          @issue.has_field?(id).should be_true
        end
      end

      it "true when issue has a field with the given name" do
        @ids_and_names.values.each do |name|
          @issue.has_field?(name).should be_true
        end
      end

      it "false when issue has a no field with the given ID or name" do
        @issue.has_field?("Completely Bogus").should be_false
      end
    end #has_field?

    describe "#is_subtask?" do
      it "true when issuetype.subtask is true" do
        data = { 'fields' => { 'issuetype' => {'subtask' => true} } }
        issue = Jiraby::Issue.new(@jira, data)
        issue.is_subtask?.should be_true
      end

      it "false when issuetype.subtask is false" do
        data = { 'fields' => { 'issuetype' => {'subtask' => false} } }
        issue = Jiraby::Issue.new(@jira, data)
        issue.is_subtask?.should be_false
      end

      it "false when issuetype.subtask is not set" do
        data = { 'fields' => { 'issuetype' => {} } }
        issue = Jiraby::Issue.new(@jira, data)
        issue.is_subtask?.should be_false
      end
    end #is_subtask?

    describe "#is_assigned?" do
      it "true when assignee is set" do
        data = { 'fields' => { 'assignee' => {'name' => 'someone'} } }
        issue = Jiraby::Issue.new(@jira, data)
        issue.is_assigned?.should be_true
      end

      it "false when assignee is nil" do
        data = { 'fields' => { 'assignee' => nil } }
        issue = Jiraby::Issue.new(@jira, data)
        issue.is_assigned?.should be_false
      end
    end #is_assigned?

    describe "#parent" do
      it "returns the parent key when issue is a subtask" do
        parent_key = 'FOO-234'
        data = {
          'fields' => {
            'parent' => {'key' => parent_key},
            'issuetype' => {'subtask' => true},
          }
        }
        issue = Jiraby::Issue.new(@jira, data)
        issue.parent.should == parent_key
      end

      it "returns nil when issue is not a subtask" do
        data = {
          'fields' => {
            'issuetype' => {'subtask' => false},
          }
        }
        issue = Jiraby::Issue.new(@jira, data)
        issue.parent.should be_nil
      end
    end #parent

    describe "#subtasks" do
      it "returns an array of subtask keys" do
        subtask_keys = ['ST-01', 'ST-02', 'ST-03']
        data = {
          'fields' => {
            'subtasks' => [
              {'key' => 'ST-01'},
              {'key' => 'ST-02'},
              {'key' => 'ST-03'},
            ]
          }
        }
        issue = Jiraby::Issue.new(@jira, data)
        issue.subtasks.should == subtask_keys
      end

      it "returns an empty array if the issue has no subtasks" do
        data = {
          'fields' => {
            'subtasks' => []
          }
        }
        issue = Jiraby::Issue.new(@jira, data)
        issue.subtasks.should == []
      end
    end #subtasks

    describe "#field_ids" do
      it "returns a sorted array of the issue's field IDs" do
        data = {
          'fields' => {
            'foo' => 'x',
            'bar' => 'y',
            'baz' => 'z',
          }
        }
        issue = Jiraby::Issue.new(@jira, data)
        issue.field_ids.should == ['bar', 'baz', 'foo']
      end
    end #field_ids

  end # Instance methods"
end


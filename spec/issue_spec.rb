require 'spec/spec_helper'

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

  describe '#field_name' do
  end

  describe '#method_missing' do
  end
end


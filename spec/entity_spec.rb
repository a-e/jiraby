require_relative 'spec_helper'

describe Jiraby::Entity do
  before(:each) do
    @ent = Jiraby::Entity.new(json_data('issue_10002.json'))
  end

  describe '#key' do
    it "passes through to Hash#key if arguments are included" do
      @ent.key('10002').should == 'id'
      @ent.key('TST-1').should == 'key'
    end

    it "returns the value in the issue's `key` field if argument is omitted" do
      @ent.key.should == 'TST-1'
    end
  end

end


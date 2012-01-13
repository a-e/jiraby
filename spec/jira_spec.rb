require 'spec_helper'

describe Jiraby::Jira do
  describe '#initialize' do
    it "raises an error for unknown API version" do
      lambda do
        Jiraby::Jira.new('jira.example.com', '1.0')
      end.should raise_error
    end

    it "accepts valid API versions" do
      jira = Jiraby::Jira.new('jira.example.com', '2.0.alpha1')
      jira.api_version.should == '2.0.alpha1'
    end

    it "prepends http:// to the URL if needed" do
      jira = Jiraby::Jira.new('jira.example.com')
      jira.url.should == 'http://jira.example.com'
    end
  end

  describe '#auth_url' do
    it "returns the full REST authorization URL" do
      jira = Jiraby::Jira.new('jira.example.com')
      jira.auth_url.should == 'http://jira.example.com/rest/auth/1/session'
    end
  end

  describe '#rest_url' do
    it "returns the full REST URL with API version and subpath" do
      jira = Jiraby::Jira.new('jira.example.com', '2')
      jira.rest_url('issue').should == 'http://jira.example.com/rest/api/2/issue'
    end
  end

  describe '#not_implemented_in' do
    it "raises an exception when API version is one of those listed" do
      jira = Jiraby::Jira.new('jira.example.com', '2.0.alpha1')
      lambda do
        jira.not_implemented_in('Issue creation', '2.0.alpha1')
      end.should raise_error
    end

    it "returns nil when API version is not one of those listed" do
      jira = Jiraby::Jira.new('jira.example.com', '2')
      jira.not_implemented_in('Issue creation', '2.0.alpha1').should be_nil
    end
  end
end


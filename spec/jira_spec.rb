require 'spec/spec_helper'

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

  describe '#login' do
    before(:each) do
      @jira = Jiraby::Jira.new('localhost:8080', '2')
    end

    it "returns true on successful login" do
      @jira.login('user', 'user').should be_true
    end

    it "returns false on invalid username" do
      @jira.login('bogus', 'bogus').should be_false
    end

    it "returns false on invalid password" do
      @jira.login('user', 'bogus').should be_false
    end

    it "returns false when Jira connection can't be made" do
      jira = Jiraby::Jira.new('localhost:12345', '2')
      jira.login('user', 'user').should be_false
    end
  end

  describe '#logout' do
    before(:each) do
      @jira = Jiraby::Jira.new('localhost:8080', '2')
    end

    it "returns true on successful logout" do
      @jira.login('user', 'user')
      @jira.logout.should be_true
    end

    it "returns false on failed logout" do
      @jira.logout.should be_false
    end

    it "returns false when Jira connection can't be made" do
      jira = Jiraby::Jira.new('localhost:12345', '2')
      jira.logout.should be_false
    end
  end

  describe '#issue' do
    before(:each) do
      @jira = Jiraby::Jira.new('localhost:8080', '2')
      @jira.login('user', 'user')
    end

    it "returns an Issue for valid issue key" do
      @jira.issue('TST-1').should be_an_instance_of(Jiraby::Issue)
    end

    it "returns nil for invalid issue key" do
      @jira.issue('BOGUS-429').should be_nil
    end
  end

  describe '#search' do
    before(:each) do
      @jira = Jiraby::Jira.new('localhost:8080', '2')
      @jira.login('user', 'user')
    end

    it "returns a JSON-style hash of data" do
      json = @jira.search('', 0, 1)
      json.keys.should include('issues')
    end

    it "limits results to max_results" do
      [1, 5, 10].each do |max_results|
        json = @jira.search('', 0, max_results)
        json['issues'].count.should be <= max_results
      end
    end
  end

  # TODO: Populate some more test issues in order to properly test this
  describe '#issue_keys' do
    before(:each) do
      @jira = Jiraby::Jira.new('localhost:8080', '2')
      @jira.login('user', 'user')
    end

    it "returns issue keys matching a JQL query" do
      @jira.issue_keys('key = TST-1').should == ['TST-1']
    end

    it "returns all issue keys when JQL is empty" do
      @jira.issue_keys('').should == ['TST-1']
    end
  end

  # TODO: Populate some more test issues in order to properly test this
  describe '#issues' do
    before(:each) do
      @jira = Jiraby::Jira.new('localhost:8080', '2')
      @jira.login('user', 'user')
    end

    it "returns a Generator" do
      @jira.issues.should be_an_instance_of(Generator)
    end

    it "yields issues matching a JQL query" do
      @jira.issues('key = TST-1').each do |issue|
        issue.key.should == 'TST-1'
      end
    end

    it "yields all issues when JQL is empty" do
      keys = @jira.issues('').collect {|i| i.key}
      keys.should == ['TST-1']
    end
  end

  # TODO: Populate some more test issues in order to properly test this
  describe '#count' do
    before(:each) do
      @jira = Jiraby::Jira.new('localhost:8080', '2')
      @jira.login('user', 'user')
    end

    it "returns the number of issues matching a JQL query" do
      @jira.count('key = TST-1').should == 1
    end

    it "returns a count of all issues when JQL is empty" do
      @jira.count('').should == 1
    end
  end

  describe '#project_meta' do
    before(:each) do
      @jira = Jiraby::Jira.new('localhost:8080', '2')
      @jira.login('user', 'user')
    end

    it "returns the project createmeta info if the project exists" do
      meta = @jira.project_meta('TST')
      meta.keys.should == ['name', 'self', 'issuetypes', 'id', 'avatarUrls', 'key']
    end

    it "returns nil if the project doesn't exist" do
      @jira.project_meta('BOGUS').should be_nil
    end
  end

  describe '#issue_types' do
    before(:each) do
      @jira = Jiraby::Jira.new('localhost:8080', '2')
      @jira.login('user', 'user')
    end

    it "returns the issue types if the project exists" do
      types = @jira.issue_types('TST')
      types.should_not be_nil
      types.keys.should == ["New Feature", "Improvement", "Task", "Sub-task", "Bug"]
    end

    it "returns nil if the project doesn't exist" do
      @jira.issue_types('BOGUS').should be_nil
    end
  end

  describe '#get' do
    before(:each) do
      @jira = Jiraby::Jira.new('localhost:8080', '2')
      @jira.login('user', 'user')
    end

    it "returns JSON data as a Ruby hash" do
      @jira.get('issue/TST-1').should be_an_instance_of(Hash)
    end

    it "returns nil for unknown subpath" do
      @jira.get('bogus/subpath').should == nil
    end
  end

  describe '#post' do
    before(:each) do
      @jira = Jiraby::Jira.new('localhost:8080', '2')
      @jira.login('user', 'user')
    end

    it "returns JSON data as a Ruby hash"

    it "returns nil for unknown subpath" do
      @jira.post('bogus/subpath').should == nil
    end
  end
end

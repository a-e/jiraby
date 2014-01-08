require_relative 'spec_helper'
require_relative 'data/jira_issues'

describe Jiraby::Jira do
  before(:each) do
    @jira = Jiraby::Jira.new('localhost:8080')
    todo_stub = RuntimeError.new("RestClient call needs a stub")
    RestClient.stub(:get).and_raise(todo_stub)
    RestClient.stub(:post).and_raise(todo_stub)
  end

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

  context "Sessions" do
    before(:each) do
      @login_response = {
        'session' => {
          'name' => 'JSESSIONID',
          'value' => '5185C2FF5854BDEADBEEFF3E31449A1E',
        }
      }
      @login_response_json = Yajl::Encoder.encode(@login_response)
    end

    describe '#login' do
      it "returns true on successful login" do
        RestClient.stub(:post).and_return(@login_response_json)
        @jira.login('user', 'user').should be_true
      end

      it "returns false on invalid credentials" do
        RestClient.stub(:post).and_raise(RestClient::Unauthorized)
        @jira.login('bogus', 'bogus').should be_false
      end

      it "returns false when Jira connection can't be made" do
        RestClient.stub(:post).and_raise(Errno::ECONNREFUSED)
        @jira.login('user', 'user').should be_false
      end
    end #login

    describe '#logout' do
      before(:each) do
      end

      it "returns true on successful logout" do
        RestClient.stub(:post).and_return(@login_response_json)
        @jira.login('user', 'user')
        RestClient.stub(:delete).and_return('{}')
        @jira.logout.should be_true
      end

      it "returns false on failed logout" do
        RestClient.stub(:delete).and_raise(RestClient::Unauthorized)
        @jira.logout.should be_false
      end

      it "returns false when Jira connection can't be made" do
        RestClient.stub(:delete).and_raise(Errno::ECONNREFUSED)
        @jira.logout.should be_false
      end
    end #logout
  end # Sessions

  describe '#issue' do
    before(:each) do
      @jira.stub(:get).and_return({})
      @jira.stub(:get).with('issue/TST-1').
        and_return(json_data('issue_10002.json'))
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
      @jira.stub(:post).with('search', anything).
        and_return(json_data('search_results.json'))
    end

    it "returns a JSON-style hash of data" do
      json = @jira.search('', 0, 1)
      json.keys.should include('issues')
    end

    it "limits results to max_results" do
      [1, 5, 10].each do |max_results|
        expect_params = {:jql => '', :startAt => 0, :maxResults => max_results}
        @jira.should_receive(:post).with('search', expect_params)
        json = @jira.search('', 0, max_results)
      end
    end
  end

  # TODO: Populate some more test issues in order to properly test this
  describe '#issue_keys' do
    before(:each) do
    end

    it "returns a list of issue keys" do
      search_results = {
        'total' => 3,
        'issues' => [
          {'key' => 'TST-1'},
          {'key' => 'TST-2'},
          {'key' => 'TST-3'},
        ]
      }
      @jira.stub(:search).and_return(search_results)

      @jira.issue_keys('project = TEST').should == ['TST-1', 'TST-2', 'TST-3']
    end

    it "combines multiple pages of results into a single list"
  end

  # TODO: Populate some more test issues in order to properly test this
  describe '#issues' do
    before(:each) do
      @jira.stub(:issue_keys => ['TST-1'])
      @jira.stub(:get).with('issue/TST-1').
        and_return(json_data('issue_10002.json'))
      # FIXME: Clean these up
      @jira.stub(:post).and_return("{}")
      RestClient.stub(:get).and_return("{}")
      RestClient.stub(:post).and_return("{}")
      RestClient.stub(:put).and_return("{}")
    end

    it "returns a Generator" do
      require 'enumerator'
      @jira.issues.should be_an_instance_of(Enumerator::Generator)
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

  describe '#count' do
    it "returns the number of issues matching a JQL query" do
      search_results = {'total' => 5}
      @jira.should_receive(:search).
        with('key = TST-1', anything, anything).
        and_return(search_results)
      @jira.count('key = TST-1').should == 5
    end

    it "returns a count of all issues when JQL is empty" do
      search_results = {'total' => 15}
      @jira.stub(:search).and_return(search_results)

      @jira.count('').should == 15
    end
  end

  describe '#project' do
    it "TODO"
  end #project

  describe '#project_meta' do
    before(:each) do
      @jira.stub(:get).with('issue/createmeta', anything).
        and_return(json_data('issue_createmeta.json'))
    end

    it "returns the project createmeta info if the project exists" do
      meta = @jira.project_meta('TST')
      expect_keys = ['name', 'self', 'issuetypes', 'id', 'avatarUrls', 'key']
      meta.keys.sort.should == expect_keys.sort
    end

    it "returns nil if the project doesn't exist" do
      @jira.project_meta('BOGUS').should be_nil
    end
  end

  describe '#get' do
    before(:each) do
    end

    it "returns JSON data as a Ruby hash" do
      response = {'todo' => 'some data'}
      response_json = Yajl::Encoder.encode(response)
      RestClient.stub(:get => response_json)
      @jira.get('issue/TST-1').should == response
    end

    it "returns nil for unknown subpath" do
      RestClient.stub(:get).and_raise(RestClient::ResourceNotFound)
      @jira.get('bogus/subpath').should == nil
    end
  end

  describe '#post' do
    before(:each) do
    end

    it "returns JSON data as a Ruby hash"

    it "returns nil for unknown subpath" do
      RestClient.stub(:post).and_raise(RestClient::ResourceNotFound)
      @jira.post('bogus/subpath').should == nil
    end
  end
end


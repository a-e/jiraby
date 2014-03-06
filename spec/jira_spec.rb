require_relative 'spec_helper'
require_relative 'data/jira_issues'

describe Jiraby::Jira do
  before(:each) do
    @jira = Jiraby::Jira.new('localhost:9292')
    todo_stub = RuntimeError.new("RestClient call needs a stub")
    #RestClient.stub(:get).and_raise(todo_stub)
    #RestClient.stub(:post).and_raise(todo_stub)
  end

  describe '#initialize' do
    it "raises an error for unknown API version" do
      lambda do
        Jiraby::Jira.new('jira.example.com', '1.0')
      end.should raise_error
    end

    it "accepts valid API versions" do
      jira = Jiraby::Jira.new('jira.example.com', '2')
      jira.api_version.should == '2'
    end

    it "accepts URL beginning with http://" do
      jira = Jiraby::Jira.new('http://jira.example.com')
      jira.url.should == 'http://jira.example.com'
    end

    it "accepts URL beginning with https://" do
      jira = Jiraby::Jira.new('https://jira.example.com')
      jira.url.should == 'https://jira.example.com'
    end

    it "prepends http:// to the URL if needed" do
      jira = Jiraby::Jira.new('jira.example.com')
      jira.url.should == 'http://jira.example.com'
    end
  end #initialize

  describe '#auth_url' do
    it "returns the full REST authorization URL" do
      jira = Jiraby::Jira.new('jira.example.com')
      jira.auth_url.should == 'http://jira.example.com/rest/auth/1/session'
    end
  end #auth_url

  describe '#not_implemented_in' do
    it "raises an exception when API version is one of those listed" do
      jira = Jiraby::Jira.new('jira.example.com', '2')
      lambda do
        jira.not_implemented_in('Issue creation', '2')
      end.should raise_error
    end

    it "returns nil when API version is not one of those listed" do
      jira = Jiraby::Jira.new('jira.example.com', '2')
      jira.not_implemented_in('Issue creation', '2.0.alpha1').should be_nil
    end
  end #not_implemented_in

  context "Sessions" do
    describe '#login' do
      it "returns true on successful login" do
        @jira.login('user', 'password').should be_true
      end

      context "returns false" do
        it "when given invalid credentials" do
          @jira.login('user', 'badpassword').should be_false
        end

        it "when RestClient::Exception occurs" do
          @jira.auth.stub(:post).and_raise(RestClient::Exception)
          @jira.login('user', 'password').should be_false
        end

        it "when Errno::ECONNREFUSED occurs" do
          @jira.auth.stub(:post).and_raise(Errno::ECONNREFUSED)
          @jira.login('user', 'password').should be_false
        end
      end
    end #login

    describe '#logout' do
      before(:each) do
      end

      it "returns true on successful logout" do
        #RestClient.stub(:post).and_return(@login_response_json)
        @jira.login('user', 'user')
        #RestClient.stub(:delete).and_return('{}')
        @jira.auth.stub(:delete).and_return('{}')
        @jira.logout.should be_true
      end

      it "returns false on failed logout" do
        @jira.auth.stub(:delete).and_raise(RestClient::Unauthorized)
        @jira.logout.should be_false
      end

      it "returns false when Jira connection can't be made" do
        #RestClient.stub(:delete).and_raise(Errno::ECONNREFUSED)
        @jira.auth.stub(:delete).and_raise(Errno::ECONNREFUSED)
        @jira.logout.should be_false
      end
    end #logout
  end # Sessions

  describe '#issue' do
    it "returns an Issue for valid issue key" do
      @jira.issue('TST-1').should be_an_instance_of(Jiraby::Issue)
    end

    it "raises IssueNotFound for invalid issue key" do
      lambda do
        @jira.issue('BOGUS-429')
      end.should raise_error(Jiraby::IssueNotFound, /Issue 'BOGUS-429' not found/)
    end
  end #issue

  describe '#create_issue' do
    before(:each) do
      @response = {
        "id" => "10000",
        "key" => "TST-24",
        "self" => "http://www.example.com/jira/rest/api/2/issue/10000"
      }
      @response_json = Yajl::Encoder.encode(@response)
    end

    it "sends a POST request to the Jira API" do
      #@jira.resource.should_receive(:post).and_return(@response_json)
      @jira.create_issue('TST', 'Bug')
    end

    it "returns a Jiraby::Issue" do
      RestClient.stub(:post => @response_json)
    end
  end #create_issue

  describe '#search' do
    before(:each) do
      #@jira.resource.stub(:post).with('search', anything).
        #and_return(json_data('search_results.json'))
    end

    it "returns an array of Issue instances" do
      issues = @jira.search('', 0, 1)
      issues.should be_an(Array)
      issues.each do |issue|
        issue.should be_a(Jiraby::Issue)
      end
    end

    it "limits results to max_results" do
      [1, 5, 10].each do |max_results|
        expect_params = {:jql => '', :startAt => 0, :maxResults => max_results}
        #@jira.resource.should_receive(:post).with('search', expect_params)
        json = @jira.search('', 0, max_results)
      end
    end
  end #search

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
  end #issue_keys

  # TODO: Populate some more test issues in order to properly test this
  describe '#issues' do
    before(:each) do
      @jira.stub(:issue_keys => ['TST-1', 'TST-2', 'TST-3'])
      @jira.stub(:issue => Jiraby::Issue.new)
      #@jira.resource.stub(:get).with('issue/TST-1').
        #and_return(json_data('issue_10002.json'))
      # FIXME: Clean these up
      #@jira.resource.stub(:post).and_return({})
      #RestClient.stub(:get).and_return({})
      #RestClient.stub(:post).and_return({})
      #RestClient.stub(:put).and_return({})
    end

    it "returns a Generator" do
      require 'enumerator'
      @jira.issues.should be_an_instance_of(Enumerator::Generator)
    end

    it "yields one Issue instance for each issue key" do
      @jira.issues.each do |issue|
        issue.should be_a(Jiraby::Issue)
      end
    end

    it "uses #issue_keys to find issues matching a JQL query" do
      jql = "key = TST-1"
      @jira.should_receive(:issue_keys).with(jql).and_return([])
      @jira.issues(jql)
    end
  end #issues

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
  end #count

  describe '#project' do
    before(:each) do
      #@jira.resource.stub(:get).and_return({})
      #@jira.resource.stub(:get).with('project/TST').and_return(json_data('project_TST.json'))
    end

    it "returns project data" do
      project = @jira.project('TST')
      project.should be_a(Jiraby::Project)
      # TODO: Verify attributes (requires fleshing out Project class)
    end

    it "raises ProjectNotFound if the project is not found" do
      lambda do
        @jira.project('BOGUS')
      end.should raise_error(Jiraby::ProjectNotFound, /Project 'BOGUS' not found/)
    end
  end #project

  describe '#project_meta' do
    before(:each) do
      #@jira.resource.stub(:get).with('issue/createmeta', anything).
        #and_return(json_data('issue_createmeta.json'))
    end

    it "returns the project createmeta info if the project exists" do
      meta = @jira.project_meta('TST')
      expect_keys = ['name', 'self', 'issuetypes', 'id', 'avatarUrls', 'key']
      meta.keys.sort.should == expect_keys.sort
    end

    it "raises ProjectNotFound if the project doesn't exist" do
      RestClient.stub(:get).and_raise(RestClient::ResourceNotFound)
      lambda do
        @jira.project_meta('BOGUS')
      end.should raise_error(Jiraby::ProjectNotFound, /Project 'BOGUS' not found/)
    end
  end #project_meta

  describe '#fields' do
    it "returns a mapping of field names to IDs" do
      @jira.fields.should == {
        "Description" => 'description',
        "Summary" => 'summary',
        "My Field" => 'customfield_123',
      }
    end
  end #fields

end


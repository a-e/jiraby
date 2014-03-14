require_relative 'spec_helper'
require_relative 'data/jira_issues'

describe Jiraby::Jira do
  before(:each) do
    @jira = Jiraby::Jira.new('localhost:9292')
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
          @jira.instance_eval do
            @auth.stub(:post).and_raise(RestClient::Exception)
          end
          @jira.login('user', 'password').should be_false
        end

        it "when Errno::ECONNREFUSED occurs" do
          @jira.instance_eval do
            @auth.stub(:post).and_raise(Errno::ECONNREFUSED)
          end
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
        @jira.instance_eval do
          @auth.stub(:delete).and_return('{}')
        end
        @jira.logout.should be_true
      end

      it "returns false on failed logout" do
        @jira.instance_eval do
          @auth.stub(:delete).and_raise(RestClient::Unauthorized)
        end
        @jira.logout.should be_false
      end

      it "returns false when Jira connection can't be made" do
        @jira.instance_eval do
          @auth.stub(:delete).and_raise(Errno::ECONNREFUSED)
        end
        @jira.logout.should be_false
      end
    end #logout
  end # Sessions

  context "REST wrappers" do
    before(:each) do
      @path = 'fake/path'
      @resource = Jiraby::JSONResource.new(@jira.base_url)
      @jira.rest.stub(:[]).with(@path).and_return(@resource)
    end

    describe "#_path_with_query" do
      it "returns path as-is if query is empty" do
        @jira._path_with_query("user/search").should == "user/search"
      end

      it "returns path with query parameters appended" do
        path = "user/search"
        query = {:username => "someone", :startAt => 0, :maxResults => 10}
        expect_path = "user/search?username=someone&startAt=0&maxResults=10"
        @jira._path_with_query(path, query).should == expect_path
      end
    end

    describe "#get" do
      it "sends a GET request" do
        @resource.should_receive(:get)
        @jira.get(@path)
      end
    end

    describe "#put" do
      it "sends a PUT request" do
        @resource.should_receive(:put)
        @jira.put(@path, {})
      end
    end

    describe "#post" do
      it "sends a POST request" do
        @resource.should_receive(:post)
        @jira.post(@path, {})
      end
    end

    describe "#delete" do
      it "sends a DELETE request" do
        @resource.should_receive(:delete)
        @jira.delete(@path)
      end
    end
  end # REST wrappers

  describe '#issue' do
    it "returns an Issue for valid issue key" do
      @jira.issue('TST-1').should be_a Jiraby::Issue
    end

    it "raises ArgumentError if key is nil" do
      lambda do
        @jira.issue(nil)
      end.should raise_error(ArgumentError, /Issue key is required/)
    end

    it "raises ArgumentError if key is empty" do
      lambda do
        @jira.issue(' ')
      end.should raise_error(ArgumentError, /Issue key is required/)
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

  describe "#enumerator" do
    it "returns an Enumerator instance" do
      enum = @jira.enumerator(:get, 'user/search')
      enum.should be_an Enumerator
    end

    it "gets multiple pages by incrementing `startAt`"

    it "works when REST method returns an Entity" do
      entity = Jiraby::Entity.new(
        :issues => [
          {:key => 'TST-1'},
          {:key => 'TST-2'},
          {:key => 'TST-3'},
        ]
      )
      @jira.stub(:get).and_return(entity)

      enum = @jira.enumerator(:get, 'fake_search', {}, 'issues')
      enum.count.should == 3
    end

    it "works when REST method returns an Array of Entity" do
      issue_keys = ['TST-1', 'TST-2', 'TST-3']
      entities = issue_keys.map {|key| Jiraby::Entity.new(:key => key)}
      @jira.stub(:get).and_return(entities)

      enum = @jira.enumerator(:get, 'fake_search')
      enum.count.should == 3
      enum.to_a.should == entities
    end

    it "supports the .next method" do
      # FIXME: For some reason, .next works fine in this test, but when
      # connected to an actual Jira instance, it blows up with
      #   SystemStackError: stack level too deep
      issue_keys = ['TST-1', 'TST-2', 'TST-3']
      entities = issue_keys.map {|key| Jiraby::Entity.new(:key => key)}
      @jira.stub(:get).and_return(entities)

      enum = @jira.enumerator(:get, 'fake_search')
      enum.next.key.should == 'TST-1'
      enum.next.key.should == 'TST-2'
      enum.next.key.should == 'TST-3'
    end
  end

  # TODO: Populate some more test issues in order to properly test this
  describe '#search' do
    before(:each) do
      @jira.stub(:issue_keys => ['TST-1', 'TST-2', 'TST-3'])
      @jira.stub(:issue => Jiraby::Issue.new(@jira))
    end

    it "returns an Enumerator" do
      require 'enumerator'
      @jira.search('project=TST').should be_an Enumerator
    end

    it "yields one Issue instance for each issue key" do
      @jira.search('project=TST').each do |issue|
        issue.should be_a Jiraby::Issue
      end
    end
  end #search

  # FIXME: Test this using the fake Jira instance
  describe '#count' do
    it "returns the number of issues matching a JQL query" do
      search_results = Jiraby::Entity.new({'total' => 5})
      @jira.should_receive(:post).
        with('search', anything).
        and_return(search_results)
      @jira.count('key = TST-1').should == 5
    end

    it "returns a count of all issues when JQL is empty" do
      search_results = Jiraby::Entity.new({'total' => 15})
      @jira.stub(:post).and_return(search_results)

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
      project.should be_a Jiraby::Project
      # TODO: Verify attributes (requires fleshing out Project class)
    end

    it "raises ProjectNotFound if the project is not found" do
      lambda do
        @jira.project('BOGUS')
      end.should raise_error(Jiraby::ProjectNotFound, /Project 'BOGUS' not found/)
    end
  end #project

  describe '#project_meta' do
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

  describe '#field_mapping' do
    it "returns a mapping of field IDs to names" do
      @jira.field_mapping.should == {
        'description' => "Description",
        'summary' => "Summary",
        'customfield_123' => "My Field",
      }
    end
  end #field_mapping

end


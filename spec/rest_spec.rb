require_relative 'spec_helper'
require_relative 'data/jira_issues'

describe Jiraby::Rest do
  before(:each) do
    @session = {'fake' => 'session'}
    @rest = Jiraby::Rest.new('http://jira.example.com/api', @session)
    todo_stub = RuntimeError.new("RestClient call needs a stub")
    RestClient.stub(:get).and_raise(todo_stub)
    RestClient.stub(:post).and_raise(todo_stub)
  end

  describe '#headers' do
    it "specifies JSON content type" do
      @rest.headers.should include(:content_type)
      @rest.headers[:content_type].should == :json
    end

    it "specifies acceptance of JSON" do
      @rest.headers.should include(:accept)
      @rest.headers[:accept].should == :json
    end

    it "includes session data in cookies" do
      @rest.headers.should include(:cookies)
      @rest.headers[:cookies].should == @session
    end
  end #headers


  describe '#url' do
    it "returns full http:// URL as-is" do
      path = "http://jira.example.com/my/rest/path"
      @rest.url(path).should == path
    end

    it "returns relative paths with base_url prepended" do
      path = "my/rest/path"
      @rest.url(path).should == "#{@rest.base_url}/my/rest/path"
    end
  end #url


  describe '#get' do
    before(:each) do
    end

    it "returns JSON data as a Ruby hash" do
      response = {'todo' => 'some data'}
      response_json = Yajl::Encoder.encode(response)
      RestClient.stub(:get => response_json)
      @rest.get('some/path').should == response
    end

    it "raises RestGetFailed for unknown path" do
      RestClient.stub(:get).and_raise(RestClient::ResourceNotFound)
      lambda do
        @rest.get('bogus/path').should == nil
      end.should raise_error(Jiraby::RestGetFailed, /Resource Not Found/)
    end
  end #get

  describe '#post' do
    before(:each) do
    end

    it "returns JSON data as a Ruby hash" do
      response = {'todo' => 'some data'}
      response_json = Yajl::Encoder.encode(response)
      RestClient.stub(:post => response_json)
      @rest.post('some/path').should == response
    end

    it "raises RestPostFailed for unknown path" do
      RestClient.stub(:post).and_raise(RestClient::ResourceNotFound)
      lambda do
        @rest.post('bogus/path')
      end.should raise_error(Jiraby::RestPostFailed, /Resource Not Found/)
    end
  end #post

end # describe Jiraby::Rest

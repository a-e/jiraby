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

  describe '#get' do
    before(:each) do
    end

    it "returns JSON data as a Ruby hash" do
      response = {'todo' => 'some data'}
      response_json = Yajl::Encoder.encode(response)
      RestClient.stub(:get => response_json)
      @rest.get('some/path').should == response
    end

    it "raises RestGetFailed for unknown subpath" do
      RestClient.stub(:get).and_raise(RestClient::ResourceNotFound)
      lambda do
        @rest.get('bogus/subpath').should == nil
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

    it "raises RestPostFailed for unknown subpath" do
      RestClient.stub(:post).and_raise(RestClient::ResourceNotFound)
      lambda do
        @rest.post('bogus/subpath')
      end.should raise_error(Jiraby::RestPostFailed, /Resource Not Found/)
    end
  end #post

end # describe Jiraby::Rest

require_relative 'spec_helper'
require 'jiraby/jira'
require 'jiraby/rest'
require 'jiraby/json_resource'

describe Jiraby::JSONResource do
  before(:each) do
    @jr = Jiraby::JSONResource.new('http://example.com')
  end

  describe "#initialize" do
    it "TODO"
  end #initialize

  describe "#[]" do
    it "returns a JSONResource instance" do
      @jr['subpath'].should be_a(Jiraby::JSONResource)
    end
  end #[]

  describe "#get" do
    it "TODO"
  end #get

  describe "#delete" do
    it "TODO"
  end #delete

  describe "#head" do
    it "TODO"
  end #head

  describe "#post" do
    it "TODO"
  end #post

  describe "#put" do
    it "TODO"
  end #put

  describe "#patch" do
    it "TODO"
  end #patch

  describe "#wrap" do
    it "TODO"
  end #wrap

  describe "#wrap_with_payload" do
    it "TODO"
  end #wrap_with_payload

  describe "#parsed_response" do
    it "parses the response and returns a Hash" do
      hash = {
        'foo' => 'bar',
        'nested' => {
          'a' => 'z',
          'x' => 'y',
        }
      }
      json = Yajl::Encoder.encode(hash)
      @jr.parsed_response(json).should == hash
    end

    it "raises JSONParseError when parsing fails" do
      lambda do
        @jr.parsed_response('bogus json')
      end.should raise_error(Jiraby::JSONParseError)
    end
  end #parsed_response

  describe "#maybe_error_response" do
    it "yields the block return value if no exception occurs" do
      expect_response = "The normalexpected response"
      got_response = @jr.maybe_error_response do
        expect_response
      end
      got_response.should == expect_response
    end

    it "yields the exception's response if a RestClient::Excception occurs" do
      exception = RestClient::Exception.new
      exception.response = "The exception response"
      got_response = @jr.maybe_error_response do
        raise exception
      end
      got_response.should == exception.response
    end
  end #maybe_error_response

end # describe Jiraby::JSONResource


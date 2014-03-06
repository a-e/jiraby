require_relative 'spec_helper'
require 'jiraby/jira'
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
    it "invokes #wrap with :_head" do
      @jr.should_receive(:wrap).with(:_get, {})
      @jr.get({})
    end
  end #get

  describe "#delete" do
    it "invokes #wrap with :_delete" do
      @jr.should_receive(:wrap).with(:_delete, {})
      @jr.delete({})
    end
  end #delete

  describe "#head" do
    it "invokes #wrap with :_head" do
      @jr.should_receive(:wrap).with(:_head, {})
      @jr.head({})
    end
  end #head

  describe "#post" do
    it "invokes #wrap_with_payload with :_post" do
      @jr.should_receive(:wrap_with_payload).with(:_post, {}, {})
      @jr.post({}, {})
    end
  end #post

  describe "#put" do
    it "invokes #wrap_with_payload with :_put" do
      @jr.should_receive(:wrap_with_payload).with(:_put, {}, {})
      @jr.put({}, {})
    end
  end #put

  describe "#patch" do
    it "invokes #wrap_with_payload with :_patch" do
      @jr.should_receive(:wrap_with_payload).with(:_patch, {}, {})
      @jr.patch({}, {})
    end
  end #patch

  describe "#wrap" do
    before(:each) do
      @headers = {}
    end

    it "invokes a REST method with additional headers and block" do
      @jr.should_receive(:_get).with(@headers).and_return('{}')
      @jr.wrap(:_get, @headers)
    end

    it "returns the parsed JSON response as a hash" do
      response_hash = {"status" => "ok"}
      @jr.should_receive(:_get).
        with(@headers).
        and_return(response_hash.to_json)
      result = @jr.wrap(:_get, @headers)
      result.should == response_hash
    end

    it "when RestClient::Exception occurs, returns exception response as a hash" do
      error_hash = {"error" => "Error message"}
      exception = RestClient::Exception.new
      exception.response = error_hash.to_json
      got_response = @jr.wrap(:_get, {}) do
        raise exception
      end
      got_response.should == error_hash
    end
  end #wrap

  describe "#wrap_with_payload" do
    before(:each) do
      @payload = {"name" => "Foo"}
      @headers = {}
    end

    it "when payload is a hash, it's encoded as JSON" do
      @jr.should_receive(:_put).with(@payload.to_json, @headers).and_return('{}')
      @jr.wrap_with_payload(:_put, @payload, @headers)
    end

    it "when payload is already a JSON string, it's sent as-is" do
      json_payload = @payload.to_json
      @jr.should_receive(:_put).with(json_payload, @headers).and_return('{}')
      @jr.wrap_with_payload(:_put, json_payload, @headers)
    end

    it "invokes a REST method with additional headers and block" do
      @headers['extra'] = 'something'
      @jr.should_receive(:_put).with(@payload.to_json, @headers).and_return('{}')
      @jr.wrap_with_payload(:_put, @payload, @headers)
    end

    it "returns the parsed JSON response as a hash" do
      json_payload = @payload.to_json
      response_hash = {"status" => "ok"}
      @jr.should_receive(:_put).
        with(json_payload, @headers).
        and_return(response_hash.to_json)
      result = @jr.wrap_with_payload(:_put, json_payload, @headers)
      result.should == response_hash
    end

    it "when RestClient::Exception occurs, returns exception response as a hash" do
      error_hash = {"error" => "Error message"}
      exception = RestClient::Exception.new
      exception.response = error_hash.to_json
      got_response = @jr.wrap_with_payload(:_put, {}, {}) do
        raise exception
      end
      got_response.should == error_hash
    end
  end #wrap_with_payload

  describe "#parsed_response" do
    it "returns a Hash if the response is a JSON object" do
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

    it "returns an Array of Hashes if the response is a JSON object array" do
      hash_array = [{'foo' => 'bar'}, {'goo' => 'car'}]
      json = Yajl::Encoder.encode(hash_array)
      @jr.parsed_response(json).should == hash_array
    end

    it "returns nil if the response is an empty string" do
      @jr.parsed_response("").should be_nil
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


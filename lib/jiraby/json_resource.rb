require 'rest_client'
require 'jiraby/entity'

module Jiraby
  class JSONParseError < RuntimeError
    attr_reader :response

    def initialize(message, response)
      super(message)
      @response = response
    end
  end

  # A RestClient::Resource that expects JSON data from all requests, and
  # wraps all JSON in native Ruby hashes so you don't have to parse it.
  #
  # Expectations:
  #
  # - All GET, HEAD, DELETE, PUT, POST, and PATCH requests to your REST API
  #   will return a JSON string. With JSONResource, the #get, #head, #delete,
  #   #put, #post, and #patch methods return a Hash (if the response is actually
  #   JSON and can be parsed), or raise a JSONParseError if parsing fails.
  #
  # - All payloads (first argument to #put, #post, and #patch) are expected to
  #   be JSON strings; you can provide the raw JSON string, or provide a Hash
  #   and it will be automatically encoded as a JSON string.
  #
  # - All error responses from the REST API are expected to be JSON strings.
  #   When an error occurs (such as 401, 404, 500 etc.), normally a
  #   RestClient::Exception is raised. With JSONResource, the error response
  #   is parsed as JSON and returned as a Hash; no exception is raised.
  #
  class JSONResource < RestClient::Resource
    def initialize(url, options={}, backwards_compatibility=nil, &block)
      options[:headers] = {} if options[:headers].nil?
      options[:headers].merge!(:content_type => :json, :accept => :json)
      super(url, options, backwards_compatibility, &block)
    end

    # Aliases to RestClient::Resource methods
    alias_method :_get, :get
    alias_method :_delete, :delete
    alias_method :_head, :head
    alias_method :_post, :post
    alias_method :_put, :put
    alias_method :_patch, :patch

    # Wrapped RestClient::Resource methods that accept and return Hash data
    def get(additional_headers={}, &block)
      wrap(:_get, additional_headers, &block)
    end

    def delete(additional_headers={}, &block)
      wrap(:_delete, additional_headers, &block)
    end

    def head(additional_headers={}, &block)
      wrap(:_head, additional_headers, &block)
    end

    def post(payload, additional_headers={}, &block)
      wrap_with_payload(:_post, payload, additional_headers, &block)
    end

    def put(payload, additional_headers={}, &block)
      wrap_with_payload(:_put, payload, additional_headers, &block)
    end

    def patch(payload, additional_headers={}, &block)
      wrap_with_payload(:_patch, payload, additional_headers, &block)
    end

    # Wrap the given method to return a Hash response parsed from JSON
    #
    def wrap(method, additional_headers={}, &block)
      response = maybe_error_response do
        send(method, additional_headers, &block)
      end
      return parsed_response(response)
    end

    # Wrap the given method to send a Hash payload, and return a Hash response
    # parsed from JSON.
    #
    def wrap_with_payload(method, payload, additional_headers={}, &block)
      if payload.is_a?(Hash)
        payload = Yajl::Encoder.encode(payload)
      end
      response = maybe_error_response do
        send(method, payload, additional_headers, &block)
      end
      return parsed_response(response)
    end

    # Parse `response` as JSON and return a Hash or array of Hashes.
    # Raise `JSONParseError` if parsing fails.
    #
    def parsed_response(response)
      begin
        json = Yajl::Parser.parse(response)
      rescue Yajl::ParseError => ex
        # FIXME: Sometimes getting "input must be a string or IO" error here
        raise JSONParseError.new(ex.message, response)
      else
        if json.is_a?(Hash)
          return Entity.new(json)
        elsif json.is_a?(Array)
          return json.collect do |hash|
            Entity.new(hash)
          end
        else
          return nil
        end
      end
    end

    # Yield a response from the given block; if a `RestClient::Exception` is
    # raised, return the exception's response instead.
    #
    def maybe_error_response(&block)
      begin
        yield
      rescue RestClient::RequestTimeout => ex
        raise ex
      rescue RestClient::Exception => ex
        ex.response
      end
    end

  end # class JSONResource
end # module Jiraby


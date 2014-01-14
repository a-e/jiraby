require 'hashie'

module Jiraby
  # REST API wrapper
  #
  # This class handles Hash <=> JSON conversions when making REST requests.
  #
  class Rest
    attr_accessor :base_url, :session

    def initialize(base_url, session_hash=nil)
      @base_url = base_url
      @session = session_hash
    end

    # Return the headers needed for most REST requests, including
    # the current session data.
    #
    # @return [Hash]
    #
    def headers
      {
        :content_type => :json,
        :accept => :json,
        :cookies => @session
      }
    end #headers


    # Return the full REST API URL for the given path.
    #
    # @param [String] path
    #   Path relative to `base_url`. If this is a full URL beginning with
    #   `http://` or `https://`, it's returned as-is.
    #
    # @return [String]
    #
    def url(path)
      if path =~ /^https?:\/\//
        return path
      else
        return File.join(@base_url, path)
      end
    end #url


    # TODO: Refactor these; the JSON encoding and parsing, and exception
    # handling, are common to get/put/post/delete

    # Submit a POST request to the given REST path, including
    # the given JSON parameters. If the request succeeds, return
    # a JSON-formatted response. Otherwise, raise `Jiraby::RestCallFailed`.
    #
    # @param [String] path
    #   The last part of the REST API path you want to POST to,
    #   or a full URL beginning with `http://` or `https://`
    # @param [Hash] params
    #   Key => value parameters to post
    #
    # @return [Hash]
    #   Raw JSON response converted to a Ruby Hash
    #
    # @raise [Jiraby::RestCallFailed]
    #
    def post(path, params={})
      url = self.url(path)
      json = Yajl::Encoder.encode(params)
      begin
        response = RestClient.post(url, json, self.headers)
      rescue => ex
        raise Jiraby::RestCallFailed.new("Failed to POST #{url}: " + ex.message)
        #return ex
      else
        # TODO: Exception handling
        return Yajl::Parser.parse(response.to_str)
      end
    end #post


    # Submit a PUT request to the given REST path, including
    # the given JSON parameters. If the request succeeds, return
    # a JSON-formatted response. Otherwise, raise `Jiraby::RestCallFailed`.
    #
    # @param [String] path
    #   The last part of the REST API path you want to PUT to,
    #   or a full URL beginning with `http://` or `https://`
    # @param [Hash] params
    #   Key => value parameters to put
    #
    # @return [Hash]
    #   Raw JSON response converted to a Ruby Hash
    #
    # @raise [Jiraby::RestCallFailed]
    #
    def put(path, params={})
      url = self.url(path)
      json = Yajl::Encoder.encode(params)
      begin
        response = RestClient.put(url, json, self.headers)
      rescue => ex
        raise Jiraby::RestCallFailed.new("Failed to PUT #{url}: " + ex.message)
        #return ex
      else
        return Yajl::Parser.parse(response.to_str)
      end
    end #put


    # Submit a DELETE request to the given REST path. If the request succeeds,
    # return a JSON-formatted response. Otherwise, raise `Jiraby::RestCallFailed`.
    def delete(path, params={})
      url = self.url(path)
      json = Yajl::Encoder.encode(params)
      begin
        response = RestClient.delete(url, json, self.headers)
      rescue => ex
        raise Jiraby::RestCallFailed.new("Failed to DELETE #{url}: " + ex.message)
        #return ex
      else
        return Yajl::Parser.parse(response.to_str)
      end
    end #delete


    # Submit a GET request to the given REST path. If the request succeeds,
    # return a JSON-formatted response. Otherwise, raise `Jiraby::RestCallFailed`.
    #
    # @param [String] path
    #   The last part of the REST API path you want to GET from,
    #   or a full URL beginning with `http://` or `https://`
    # @param [Hash] params
    #   Key => value parameters to include in the request
    #
    # @return [Hash, nil]
    #   Raw JSON response converted to a Ruby Hash, or nil
    #   if the request failed.
    #
    # @raise [Jiraby::RestCallFailed]
    #   If the request failed
    #
    def get(path, params={})
      url = self.url(path)
      merged_params = self.headers.merge({:params => params})
      begin
        response = RestClient.get(url, merged_params)
      rescue => ex
        raise Jiraby::RestCallFailed.new("Failed to GET #{url}: " + ex.message)
        #return ex
      else
        # TODO: Exception handling
        return Yajl::Parser.parse(response.to_str)
      end
    end #get

    def request(method, *args)
    end

  end # class Rest
end # module Jiraby


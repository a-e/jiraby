
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


    # Submit a POST request to the given REST subpath, including
    # the given JSON parameters. If the request succeeds, return
    # a JSON-formatted response. Otherwise, raise `Jiraby::RestPostFailed`.
    #
    # @param [String] subpath
    #   The last part of the REST API path you want to post to
    # @param [Hash] params
    #   Key => value parameters to post
    #
    # @return [Hash]
    #   Raw JSON response converted to a Ruby Hash, or nil
    #   if the request failed.
    #
    # @raise [Jiraby::RestPostFailed]
    #
    # TODO: Factor this out into a mixin or superclass
    #
    def post(subpath, params={})
      url = File.join(@base_url, subpath)
      json = Yajl::Encoder.encode(params)
      begin
        response = RestClient.post(url, json, self.headers)
      rescue RestClient::ResourceNotFound => ex
        raise Jiraby::RestPostFailed.new(ex.message)
      else
        return Yajl::Parser.parse(response.to_str)
      end
    end #post


    # Submit a GET request to the given REST subpath. If the request succeeds,
    # return a JSON-formatted response. Otherwise, return nil.
    #
    # @param [String] subpath
    #   The last part of the REST API path you want to post to
    # @param [Hash] params
    #   Key => value parameters to include in the request
    #
    # @return [Hash, nil]
    #   Raw JSON response converted to a Ruby Hash, or nil
    #   if the request failed.
    #
    # TODO: Factor this out into a mixin or superclass
    #
    def get(subpath, params={})
      url = File.join(@base_url, subpath)
      merged_params = self.headers.merge({:params => params})
      begin
        response = RestClient.get(url, merged_params)
      rescue RestClient::ResourceNotFound => ex
        raise Jiraby::RestGetFailed.new(ex.message)
      else
        return Yajl::Parser.parse(response.to_str)
      end
    end #get



  end # class Rest
end # module Jiraby


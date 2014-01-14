require 'jiraby/resource'

# Access various resources from a Jira API.
module Jiraby
  # Example:
  #
  #     rest = Jiraby::Rest.new("http://example.com/rest/api/2")
  #     issue_api = Jiraby::ResourceAPI.new(rest, 'issue')
  #
  #     issue = issue_api.get('TST-1') # GET example.com/rest/api/2/issue/TST-1
  #
  class ResourceAPI
    attr_reader :name

    def initialize(rest_instance, resource_name)
      # TODO: Validation
      @rest = rest_instance
      @name = resource_name
    end

    # Return the base URL for this kind of resource
    def base_url
      return @rest.rest_url(@name)
    end

    # `GET /<name>` and return a `Resource`
    def get(*path)
      subpath = File.join(@name, *path)
      json_data = @rest.get(subpath)
      return Resource.new(json_data)
    end

    # `POST /<name>` with `data`
    def post(data={}, *path)
      subpath = File.join(@name, *path)
      json_data = @rest.post(subpath, data)
      return Resource.new(json_data)
    end
  end # class ResourceAPI
end # module Jiraby

require 'jiraby/resource'

# Access various resources from a Jira API.
module Jiraby
  class ResourceAPI
    attr_reader :name

    # Example:
    #
    #     issue_api = Jiraby::ResourceAPI.new(jira, 'issue')
    #     issue = issue_api.get('TST-1')
    #
    def initialize(jira_instance, resource_name)
      # TODO: Validation
      @jira = jira_instance
      @name = resource_name
    end

    # Return the base URL for this kind of resource
    def base_url
      return @jira.rest_url(@name)
    end

    # `GET /<name>` and return a `Resource`
    def get(*path)
      subpath = File.join(@name, *path)
      json_data = @jira.get(subpath)
      return Resource.new(json_data)
    end

    # `POST /<name>` with `data`
    def post(data={}, *path)
      subpath = File.join(@name, *path)
      json_data = @jira.post(subpath, data)
      return Resource.new(json_data)
    end
  end # class ResourceAPI
end # module Jiraby

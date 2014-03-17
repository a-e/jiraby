# Builtin
require 'enumerator'

# Gems
require 'rubygems'
require 'yajl'
require 'rest_client'

# Local
require 'jiraby/issue'
require 'jiraby/project'
require 'jiraby/exceptions'
require 'jiraby/json_resource'

module Jiraby
  # Wrapper for Jira
  class Jira
    @@max_results = 50

    # Initialize a Jira instance at the given URL.
    #
    # @param [String] url
    #   Full URL of the JIRA instance to connect to. If this does not begin
    #   with http: or https:, then http:// is assumed.
    # @param [String] username
    #   Jira username
    # @param [String] password
    #   Jira password
    # @param [String] api_version
    #   The API version to use. For now, only '2' is supported.
    #
    # TODO: Handle the case where the wrong API version is used for a given
    # Jira instance (should give 404s when resources are requested)
    def initialize(url, username, password, api_version='2')
      if !known_api_versions.include?(api_version)
        raise ArgumentError.new("Unknown Jira API version: #{api_version}")
      end
      if url =~ /https:|http:/
        @url = url
      else
        @url = "http://#{url}"
      end
      @credentials = {:user => username, :password => password}
      @api_version = api_version
      @_field_mapping = nil

      @rest = Jiraby::JSONResource.new(base_url, @credentials)
    end #initialize

    attr_reader :url, :api_version, :rest

    # Return a list of known Jira API versions.
    #
    def known_api_versions
      return ['2']
    end #known_api_versions


    # Return the URL for authenticating to Jira.
    #
    def auth_url
      "#{@url}/rest/auth/1/session"
    end #auth_url

    def base_url
      "#{@url}/rest/api/#{@api_version}"
    end

    # Raise an exception if the current API version is one of those listed.
    #
    # @param [String] feature
    #   Name or short description of the feature in question
    # @param [Array] api_versions
    #   One or more version strings for Jira APIs that do not support the
    #   feature in question
    #
    def not_implemented_in(feature, *api_versions)
      if api_versions.include?(@api_version)
        raise NotImplementedError,
          "#{feature} not supported by version #{@api_version} of the Jira API"
      end
    end #not_implemented_in

    # Return a URL query, suitable for use in a GET/DELETE/HEAD request
    # that accepts queries like `?var1=value1&var2=value2`.
    def _path_with_query(path, query={})
      # TODO: Escape special chars
      params = query.map {|k,v| "#{k}=#{v}"}.join("&")
      if params.empty?
        return path
      else
        return "#{path}?#{params}"
      end
    end

    # REST wrapper methods returning Jiraby::Entity
    def get(path, query={})
      @rest[_path_with_query(path, query)].get
    end

    def delete(path, query={})
      @rest[_path_with_query(path, query)].delete
    end

    def put(path, data)
      @rest[path].put data
    end

    def post(path, data)
      @rest[path].post data
    end

    #
    #
    # TODO: Hack out everything below this and move it to higher-level
    # abstractions. Keep the Jira class low-level.
    #
    #

    # Find all issues matching the given JQL query, and return an
    # `Enumerator` that yields each one as an Issue object.
    # Each Issue is fetched from the REST API as needed.
    #
    # @param [String] jql_query
    #   JQL query for the issues you want to match
    #
    # @return [Enumerator]
    #
    def search(jql_query)
      params = {
        :jql => jql_query,
      }
      issues = self.enumerator(:post, 'search', params, 'issues')
      return Enumerator.new do |e|
        issues.each do |data|
          e << Issue.new(self, data)
        end
      end
    end

    # Return an Enumerator yielding items returned by a REST method that
    # accepts `startAt` and `maxResults` parameters. This allows you to
    # iterate through large data sets
    #
    # For example, using the issue `search` method to look up all issues
    # in project "FOO", then using `each` to iterate over them:
    #
    #   query = 'project=FOO order by key'
    #   jira.enumerator(
    #     :post, 'search', {:jql => query}, 'issues'
    #   ).each do |issue|
    #     puts "#{issue.key}: #{issue.fields.summary}"
    #   end
    #
    # The output might be:
    #
    #   FOO-1: First issue in Foo project
    #   FOO-2: Another issue
    #   (...)
    #   FOO-149: Penultimate issue
    #   FOO-150: Last issue
    #
    # Below is a complete list of Jira REST API methods that accept `startAt`
    # and `maxResults`.
    #
    # Returning Entity:
    #   GET /dashboard => { 'dashboards' => [...], 'total' => N } (dashboards)
    #   GET /search => { 'issues' => [...], 'total' => N } (issues)
    #   POST /search => { 'issues' => [...], 'total' => N } (issues)
    #
    # Returning Array of Entity:
    #   GET /user/assignable/multiProjectSearch => [...] (users)
    #   GET /user/assignable/search => [...] (users)
    #   GET /user/permission/search => [...] (users)
    #   GET /user/search => [...] (users)
    #   GET /user/viewissue/search => [...] (users)
    #
    def enumerator(method, path, params={}, list_key=nil)
      max_results = @@max_results
      return Enumerator.new do |enum|
        page = 0
        more = true
        while(more) do
          paged_params = params.merge({
            :startAt => page * max_results,
            :maxResults => max_results
          })
          response = self.send(method, path, paged_params)

          # Some methods (like 'search') return an Entity, with the list of
          # items indexed by `list_key`.
          if response.is_a?(Jiraby::Entity)
            items = response[list_key]
          # Others (like 'user/search') return an array of Entity.
          elsif response.is_a?(Array)
            items = response
          else
            raise RuntimeError.new("Unexpected data: #{response}")
          end

          items.to_a.each do |item|
            enum << item
          end

          if items.to_a.count < max_results
            more = false
          else
            page += 1
          end
        end # while(more)
      end # Enumerator.new
    end

    # Return the Issue with the given key.
    #
    # @param [String] key
    #   The issue's unique identifier (usually like PROJ-NNN)
    #
    # @return [Issue]
    #   An Issue populated with data returned by the API
    #
    # @raise [IssueNotFound]
    #   If the issue was not found or fetching failed
    #
    def issue(key)
      if key.nil? || key.to_s.strip.empty?
        raise ArgumentError.new("Issue key is required")
      end
      json = self.get "issue/#{key}"
      if json and (json.empty? or json['errorMessages'])
        raise IssueNotFound.new("Issue '#{key}' not found in Jira")
      else
        return Issue.new(self, json)
      end
    end #issue


    # Create a new issue
    #
    # @param [String] project_key
    #   Identifier for the project to create the issue under
    # @param [String] issue_type
    #   The name of an issue type. May be any issue types accepted by the given
    #   project; typically "Bug", "Task", "Improvement", "New Feature", or
    #   "Sub-task"
    #
    # @return [Issue]
    #
    def create_issue(project_key, issue_type='Bug')
      issue_data = self.post 'issue', {
        "fields" => {"project" => {"key" => project_key} }
      }
      return Issue.new(self, issue_data) if issue_data
      return nil
    end #create_issue


    # Return the Project with the given key.
    #
    # @param [String] key
    #   The project's unique identifier (usually like PROJ)
    #
    # @return [Project]
    #   A Project populated with data returned by the API, or
    #   nil if no such project is found.
    #
    def project(key)
      json = self.get "project/#{key}"
      if json and (json.empty? or json['errorMessages'])
        raise ProjectNotFound.new("Project '#{key}' not found in Jira")
      else
        return Project.new(json)
      end
    end #project


    # Return the 'createmeta' data for the given project key, or nil if
    # the project is not found.
    #
    # TODO: Move this into the Project class?
    #
    def project_meta(project_key)
      meta = self.get 'issue/createmeta?expand=projects.issuetypes.fields'
      metadata = meta.projects.find {|proj| proj['key'] == project_key}
      if metadata and !metadata.nil?
        return metadata
      else
        raise ProjectNotFound.new("Project '#{project_key}' not found in Jira")
      end
    end #project_meta


    # Return the total number of issues matching the given JQL query, or
    # the count of all issues if no JQL query is given.
    #
    # @param [String] jql
    #   JQL query for the issues you want to match
    #
    # @return [Integer]
    #   Number of issues matching the query
    #
    def count(jql='')
      result = self.post 'search', {
        :jql => jql,
        :startAt => 0,
        :maxResults => 1,
        :fields => [''],
      }
      return result.total
    end #count


    # Return a hash of {'field_id' => 'Field Name'} for all fields
    def field_mapping
      if @_field_mapping.nil?
        ids_and_names = self.get('field').collect { |f| [f.id, f.name] }
        @_field_mapping = Hash[ids_and_names]
      end
      return @_field_mapping
    end #field_mapping

  end # class Jira
end # module Jiraby

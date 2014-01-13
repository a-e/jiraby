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
require 'jiraby/rest'

module Jiraby

  class Jira
    # Initialize a Jira instance at the given URL.
    # Call {#login} separately to log into Jira.
    #
    # @param [String] url
    #   Full URL of the JIRA instance to connect to. If this does not begin
    #   with http: or https:, then http:// is assumed.
    # @param [String] api_version
    #   The API version to use. For now, only '2' is supported.
    #
    # TODO: Handle the case where the wrong API version is used for a given
    # Jira instance (should give 404s when resources are requested)
    def initialize(url, api_version='2')
      if !known_api_versions.include?(api_version)
        raise ArgumentError.new("Unknown Jira API version: #{api_version}")
      end
      if url =~ /https:|http:/
        @url = url
      else
        @url = "http://#{url}"
      end
      @api_version = api_version
      @rest = Rest.new("#{@url}/rest/api/#{@api_version}")
    end #initialize

    attr_reader :url, :api_version
    attr_accessor :rest

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


    # Login to Jira using the given username/password.
    #
    # @param [String] username
    #   Log in as this user
    # @param [String] password
    #   Password for the given username
    #
    # @return [Bool]
    #   `true` if login was successful, `false` otherwise
    #
    def login(username, password)
      request_json = Yajl::Encoder.encode({
        :username => username,
        :password => password,
      })
      @rest.session = nil
      # TODO: Factor this out into Jiraby::Rest methods
      begin
        response = RestClient.post(
          auth_url, request_json,
          :content_type => :json, :accept => :json)
      # TODO: Somehow log or otherwise indicate the cause of failure here
      rescue RestClient::Unauthorized => e
        return false
      rescue Errno::ECONNREFUSED => e
        return false
      else
        session = Yajl::Parser.parse(response.to_str)['session']
        @rest.session = {session['name'] => session['value']}
        return true
      end
    end #login


    # Log out of Jira
    def logout
      begin
        # TODO: Wrap in @rest.delete
        RestClient.delete(auth_url, @rest.headers)
      # TODO: Somehow log or otherwise indicate the cause of failure here
      rescue RestClient::Unauthorized => e
        return false
      rescue Errno::ECONNREFUSED => e
        return false
      end
      return true
    end #logout



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


    #
    #
    # TODO: Hack out everything below this and move it to higher-level
    # abstractions. Keep the Jira class low-level.
    #
    #

    # Invoke the 'search' method to find issues matching the given JQL query,
    # and return the raw JSON response.
    #
    # @param [String] jql
    #   JQL query for the issues you want to match
    # @param [Integer, String] start_at
    #   0-based index of the first issue to match
    # @param [Integer, String] max_results
    #   Maximum number of issues to return
    #
    def search(jql, start_at=0, max_results=50)
      return @rest.post(
        'search',
        {
          :jql => jql,
          :startAt => start_at.to_i,
          :maxResults => max_results.to_i,
        }
      )
    end #search

    # Return the Issue with the given key.
    #
    # @param [String] key
    #   The issue's unique identifier (usually like PROJ-NNN)
    #
    # @return [Issue]
    #   An Issue populated with data returned by the API, or
    #   nil if no such issue is found.
    #
    def issue(key)
      json = @rest.get("issue/#{key}")
      if json and !json.empty?
        return Issue.new(json)
      else
        raise IssueNotFound.new("Issue '#{key}' not found in Jira")
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
      issue_data = @rest.post(
        'issue', {"fields" => {"project" => {"id" => project_key} } }
      )
      return Issue.new(issue_data) if issue_data
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
      project = @rest.get("project/#{key}")
      if project and !project.empty?
        return Project.new(project)
      else
        raise ProjectNotFound.new("Project '#{key}' not found in Jira")
      end
    end #project


    # Return the 'createmeta' data for the given project key, or nil if
    # the project is not found.
    #
    # TODO: Move this into the Project class
    #
    def project_meta(project_key)
      meta = @rest.get('issue/createmeta', {'expand' => 'projects.issuetypes.fields'})
      metadata = meta['projects'].find {|proj| proj['key'] == project_key}
      if metadata and !metadata.nil?
        return metadata
      else
        raise ProjectNotFound.new("Project '#{project_key}' not found in Jira")
      end
    end #project_meta


    # Return a mapping of all field names (labels) to field IDs
    def fields
      result = {}
      @rest.get('field').each do |field|
        result[field['name']] = field['id']
      end
      return result
    end #fields


    # Return the total number of issues matching the given JQL query.
    #
    # @param [String] jql
    #   JQL query for the issues you want to match
    #
    # @return [Integer]
    #   Number of issues matching the query
    #
    def count(jql='')
      return search(jql, 0, 1)['total']
    end #count


    # Return all of the issue keys matching the given JQL query.
    #
    # @param [String] jql
    #   JQL query for the issues you want to match
    #
    # @return [Array<String>]
    #   The keys of all issues matching the query
    #
    def issue_keys(jql='')
      # Issue keys will be accumulated here
      keys = []
      # Fetch up to 50 issue keys at a time
      max_results = 50
      start = 0

      # Get the first batch
      results = search(jql, start, max_results)

      # Until we've gotten all the issues, get successive batches
      while results['total'] >= (start + results['issues'].length)
        keys.concat(results['issues'].collect {|iss| iss['key']})
        start += max_results
        results = search(jql, start, max_results)
      end

      return keys
    end #issue_keys


    # Find all issues matching the given JQL query, and return an
    # `Enumerator::Generator` that yields each one as an Issue object.
    # Each Issue is fetched from the REST API as needed.
    #
    # @param [String] jql
    #   JQL query for the issues you want to match
    #
    # @return [Enumerator::Generator]
    #
    def issues(jql='')
      keys = issue_keys(jql)
      issue_generator = Enumerator::Generator.new do |g|
        for key in keys
          g.yield issue(key)
        end
      end
      return issue_generator
    end #issues

  end # class Jira
end # module Jiraby

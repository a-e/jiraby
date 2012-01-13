# Builtin
require 'generator'

# Gems
require 'rubygems'
require 'yajl'
require 'rest_client'

# Local
require 'jiraby/issue'

# JIRA REST API Methods
# (Full list: http://docs.atlassian.com/jira/REST/latest/)
#
# /auth/1/session
# /auth/1/websudo
# /api/2.0.alpha1/issueLink
# /api/2.0.alpha1/issue/{issueKey}
# /api/2.0.alpha1/issue/{issueKey}/transitions
# /api/2.0.alpha1/issue/{issueKey}/votes
# /api/2.0.alpha1/issue/{issueKey}/watchers
# /api/2.0.alpha1/groups/picker?query
# /api/2.0.alpha1/version
# /api/2.0.alpha1/version/{id}?moveFixIssuesTo&moveAffectedIssuesTo
# /api/2.0.alpha1/version/{id}/relatedIssueCounts
# /api/2.0.alpha1/version/{id}/unresolvedIssueCount
# /api/2.0.alpha1/version/{id}/move
# /api/2.0.alpha1/comment/{id}?render
# /api/2.0.alpha1/project/{projectKey}/role
# /api/2.0.alpha1/project/{projectKey}/role/{id}
# /api/2.0.alpha1/user?username
# /api/2.0.alpha1/serverInfo
# /api/2.0.alpha1/component
# /api/2.0.alpha1/component/{id}?moveIssuesTo
# /api/2.0.alpha1/component/{id}/relatedIssueCounts
# /api/2.0.alpha1/search?jql&startAt&maxResults
# /api/2.0.alpha1/project
# /api/2.0.alpha1/project/{key}
# /api/2.0.alpha1/project/{key}/versions
# /api/2.0.alpha1/project/{key}/components
# /api/2.0.alpha1/status/{id}
# /api/2.0.alpha1/issueLinkType
# /api/2.0.alpha1/issueLinkType/{issueLinkTypeId}
# /api/2.0.alpha1/customFieldOption/{id}
# /api/2.0.alpha1/resolution/{id}
# /api/2.0.alpha1/issueType/{id}
# /api/2.0.alpha1/attachment/{id}
# /api/2.0.alpha1/priority/{id}
# /api/2.0.alpha1/application-properties?key&value
# /api/2.0.alpha1/worklog/{id}
# /api/2.0.alpha1/issue/{issueKey}/attachments

module Jiraby

  class Jira
    # Initialize a Jira instance at the given URL.
    # Call {#login} separately to log into Jira.
    #
    # @param [String] url
    #   Full URL of the JIRA instance to connect to. If this does not begin
    #   with http: or https:, then http:// is assumed.
    # @param [String] api_version
    #   The API version to use (`2.0.alpha1` for Jira 4.x, `2` for Jira 5.x)
    #
    def initialize(url, api_version='2.0.alpha1')
      if !known_api_versions.include?(api_version)
        raise ArgumentError.new("Unknown Jira API version: #{api_version}")
      end
      if url =~ /https:|http:/
        @url = url
      else
        @url = "http://#{url}"
      end
      @api_version = api_version
      @rest_session = nil
    end

    attr_reader :url, :api_version


    # Return a list of known Jira API versions.
    #
    def known_api_versions
      return ['2.0.alpha1', '2']
    end


    # Return the URL for authenticating to Jira.
    #
    def auth_url
      "#{@url}/rest/auth/1/session"
    end


    # Return the full URL for the given REST API subpath.
    #
    # @param [String] subpath
    #   The last part of the REST API path
    #
    # @return [String]
    #   The full URL for the given REST API subpath
    #
    def rest_url(subpath)
      "#{@url}/rest/api/#{@api_version}/#{subpath}"
    end


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
      begin
        response = RestClient.post(
          auth_url, request_json,
          :content_type => :json, :accept => :json)
      # TODO: Somehow log or otherwise indicate the cause of failure here
      rescue RestClient::Unauthorized => e
        return false
      rescue Errno::ECONNREFUSED => e
        return false
      end
      if response
        session = Yajl::Parser.parse(response.to_str)['session']
        @rest_session = {session['name'] => session['value']}
      # TODO: Determine if it's even possible to get here
      else
        @rest_session = nil
      end
      return !@rest_session.nil?
    end


    # Log out of Jira
    def logout
      begin
        RestClient.delete(auth_url, headers)
      # TODO: Somehow log or otherwise indicate the cause of failure here
      rescue RestClient::Unauthorized => e
        return false
      rescue Errno::ECONNREFUSED => e
        return false
      end
      return true
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
        :cookies => @rest_session
      }
    end


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
      return post(
        'search',
        {
          :jql => jql,
          :startAt => start_at.to_i,
          :maxResults => max_results.to_i,
        }
      )
    end


    # Return the Issue with the given key.
    #
    # @param [String] key
    #   The issue's unique identifier (usually like PROJ-NNN)
    #
    # @return [Issue]
    #   An Issue populated with data returned by the API
    #
    def issue(key)
      json = get("issue/#{key}")
      if json
        return Jiraby::Issue.new(json)
      else
        return nil
      end
    end


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
    end


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
    end


    # Find all issues matching the given JQL query, and return a Generator
    # that yields each one as an Issue object. Each Issue is fetched from
    # the REST API as needed.
    #
    # @param [String] jql
    #   JQL query for the issues you want to match
    #
    # @return [Generator]
    #
    def issues(jql='')
      keys = issue_keys(jql)
      issue_generator = Generator.new do |g|
        for key in keys
          g.yield issue(key)
        end
      end
      return issue_generator
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
    end

    # Submit a POST request to the given REST subpath, including
    # the given JSON parameters. If the request succeeds, return
    # a JSON-formatted response. Otherwise, return nil.
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
    # TODO: Factor this out into a mixin or superclass
    #
    def post(subpath, params={})
      json = Yajl::Encoder.encode(params)
      begin
        response = RestClient.post(rest_url(subpath), json, headers)
      rescue RestClient::ResourceNotFound
        return nil
      else
        return Yajl::Parser.parse(response.to_str)
      end
    end


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
      merged_params = headers.merge({:params => params})
      begin
        response = RestClient.get(rest_url(subpath), merged_params)
      rescue RestClient::ResourceNotFound
        return nil
      else
        return Yajl::Parser.parse(response.to_str)
      end
    end

  end
end

# Builtin
require 'generator'

# Gems
require 'rubygems'
require 'yajl'
require 'rest_client'

# Local
require 'jiraby/issue'

module Jiraby

  class Jira
    # Initialize a Jira instance with the given parameters.
    # Call {#login} separately to log into Jira.
    def initialize(url, opts={})
      @url = url
      @opts = opts
      @rest_session = nil
    end


    # Return the URL for authenticating to Jira
    def auth_url
      "#{@url}/rest/auth/1/session"
    end


    # Return the URL for the Jira REST API path, followed by the given subpath
    def rest_url(subpath)
      "#{@url}/rest/api/2.0.alpha1/#{subpath}"
    end


    # Login to Jira using the given username/password
    def login(username, password)
      request_json = Yajl::Encoder.encode({
        :username => username,
        :password => password,
      })
      # TODO: Handle 401 unauthorized
      response = RestClient.post(
        auth_url, request_json,
        :content_type => :json, :accept => :json)
      if response
        session = Yajl::Parser.parse(response.to_str)['session']
        @rest_session = {session['name'] => session['value']}
      else
        @rest_session = nil
      end
      return !@rest_session.nil?
    end


    # Log out of Jira
    def logout
      # TODO: Handle 401 unauthorized
      RestClient.delete(auth_url, headers)
    end


    def headers
      {
        :content_type => :json,
        :accept => :json,
        :cookies => @rest_session
      }
    end


    def search(jql, start_at, max_results)
      return post(
        'search',
        {
          :jql => jql,
          :startAt => start_at,
          :maxResults => max_results,
        }
      )
    end


    # Return the Issue with the given key.
    def issue(key)
      return Jiraby::Issue.new(get("issue/#{key}"))
    end


    # Return the total number of issues matching the given JQL query.
    def count(jql='')
      search(jql, 0, 1)['total']
    end


    # Return all of the issue keys matching the given JQL query.
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


    # Yield all of the Issues matching the given JQL query.
    def issues(jql='')
      keys = issue_keys(jql)
      issue_generator = Generator.new do |g|
        for key in keys
          g.yield issue(key)
        end
      end
      return issue_generator
    end


    # Submit a POST request to the given REST subpath, including
    # the given JSON parameters. If the request succeeds, return
    # a JSON-formatted response. Otherwise, return nil.
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
    def get(subpath)
      begin
        response = RestClient.get(rest_url(subpath), headers)
      rescue RestClient::ResourceNotFound
        return nil
      else
        return Yajl::Parser.parse(response.to_str)
      end
    end

    # Methods:
    # Full list: http://docs.atlassian.com/jira/REST/latest/
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
    #
  end
end

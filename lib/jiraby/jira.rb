require 'rubygems'
require 'yajl'
require 'rest_client'
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
      # TODO
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
        rest_url('search'),
        {
          :jql => jql,
          :startAt => start_at,
          :maxResults => max_results,
        }
      )
    end


    # Return the issue with the given key
    def issue(key)
      return Jiraby::Issue.new(get("issue/#{key}"))
    end

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

Jiraby
======
[![Build Status](https://secure.travis-ci.org/a-e/jiraby.png?branch=dev)](http://travis-ci.org/a-e/jiraby)

Jiraby is a Ruby wrapper for the [JIRA](http://www.atlassian.com/JIRA)
[REST API](https://docs.atlassian.com/jira/REST/latest/), supporting Jira
versions 6.x onward.

- [Source](https://github.com/a-e/jiraby)
- [Documentation](http://rubydoc.info/github/a-e/jiraby/master/frames)
- [Gem](http://rubygems.org/gems/jiraby)
- [Status](https://travis-ci.org/a-e/jiraby)


Install
-------

Just do:

    $ gem install jiraby

Or add:

    gem 'jiraby'

to your project's Gemfile or gemspec.


Connect to Jira
---------------

Assuming your JIRA site is at `http://jira.enterprise.com`, and you have
an account `picard` with password `earlgrey`, you can connect like so:

    require 'jiraby'

    host = 'jira.enterprise.com:8080' # :PORT is optional
    username = 'picard'
    password = 'earlgrey'

    jira = Jiraby::Jira.new(host, username, password)

[HTTP basic](http://en.wikipedia.org/wiki/Basic_access_authentication)
authentication is used for all requests.


REST API
--------

Methods in the [JIRA REST API](https://docs.atlassian.com/jira/REST/6.2/) can be
accessed directly using the `#get`, `#put`, `#post`, and `#delete` methods:

    jira.get 'serverInfo'                         # info about Jira server
    jira.get 'issue/TEST-1'                       # full details of TEST-1 issue
    jira.get 'field'                              # all fields, both System and Custom
    jira.get 'user/search', :username => 'bob'    # all users matching "bob"
    jira.get 'user/search?username=bob'           # all users matching "bob"

    jira.put 'issue/TEST-1', :fields => {         # set one or more fields
      :summary => "Modified summary",
      :description => "New description"
    }

    jira.delete 'issue/TEST-1'                    # delete issue TEST-1

All REST methods return a `Jiraby::Entity` (a hash-like object built directly from
the JSON response), or an `Array` of them (for those REST methods that return arrays).


Issue wrapper
-------------

You can look up a Jira issue using the `#issue` method:

    issue = jira.issue('myproj-15')
    issue = jira.issue('MYPROJ-15') # case-insensitive

    issue.class
    # => Jiraby::Issue

If you're interested, view the raw data returned from Jira:

    issue.data
    # => {
    #   'id' => '10024',
    #   'key' => 'MYPROJ-15',
    #   'self' => 'http://jira.enterprise.com:8080/rest/api/2/issue/10024',
    #   'fields' => {
    #     'summary' => 'Realign the dilithium stabilizer matrix.',
    #     ...
    #   }
    # }

Or use the higher-level methods provided by the `Issue` class:

    issue['foo']              # Value of field 'foo'; same as `issue.data.fields.foo`
    issue['foo'] = "Newval"   # Assign to field 'foo'
    issue.subtasks            # Array of issue keys for this issue's subtasks
    issue.is_subtask?         # True if issue is a sub-task of another issue
    issue.parent              # For subtasks, issue key of parent issue
    issue.is_assigned?        # True if issue is assigned

When modifying fields, the changes will appear in the `Issue` instance immediately:

    issue['summary'] = "Modified summary"

    issue['summary']
    # => "Modified summary"

But these changes are not saved back to Jira until you call `#save!`. Before
saving, you can check for pending changes:

    issue.pending_changes?
    # => true

    issue.pending_changes
    # => {"summary" => "Modified summary"}

Then save the updates back to Jira:

    issue.save!
    # => true


Enumerator wrapper
------------------

Several of Jira's REST API methods return their data in batches, based on the
value of `startAt` and `maxResults` parameters, effectively breaking larger
result sets into pages. Since it's likely you'll want to eventually fetch all
pages of results, the `Jiraby::Jira` class can wrap such methods in an
`Enumerator`, via the `#enumerator` method.

For example, using the issue `search` method to look up all issues in project
"FOO", then using `.each` to iterate over them:

    query = 'project=FOO order by key'
    jira.enumerator(
      :post, 'search', {:jql => query}, 'issues'
    ).each do |issue|
      puts "#{issue.key}: #{issue.fields.summary}"
    end

The output might be:

    FOO-1: First issue in Foo project
    FOO-2: Another issue
    (...)
    FOO-149: Penultimate issue
    FOO-150: Last issue

Because the `search` method is so useful, it includes a wrapper of its own; all
you need to provide is a JQL query:

    issues = jira.search('project=FOO order by key')
    # => #<Enumerator: ...>

This `Enumerator` spits out `Issue` instances. Simply iterate over the issues
using `.each`, `.map`, `.select` or their ilk, and each page will be fetched
as it's needed, transparently:

    issues.each do |issue|
      puts "#{issue.key}: #{issue['summary']}"
    end

    issue_keys = issues.map { |issue| issue.key }

    unassigned_subtasks = issues.select do |issue|
      !issue.is_assigned? && issue.is_subtask?
    end

Using the `Enumerator` prevents having to load the entire list of issues into
memory at once, but can mean doing a lot of requests to Jira. If you plan to
iterate through the issues more than once and would like to avoid repeated
requests to the REST API, you could convert the `Enumerator` to an `Array`:

    issues_array = issues.to_a

Below is a complete list of Jira REST API methods that accept `startAt`
and `maxResults`.

Returning `Jiraby::Entity`:

    GET /dashboard => { 'dashboards' => [...], 'total' => N } (dashboards)
    GET /search => { 'issues' => [...], 'total' => N } (issues)
    POST /search => { 'issues' => [...], 'total' => N } (issues)

Returning `Array` of `Jiraby::Entity`:

    GET /user/assignable/multiProjectSearch => [...] (users)
    GET /user/assignable/search => [...] (users)
    GET /user/permission/search => [...] (users)
    GET /user/search => [...] (users)
    GET /user/viewissue/search => [...] (users)


Copyright
---------

The MIT License

Copyright (c) 2014 Eric Pierce

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


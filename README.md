Jiraby
======

Jiraby is a Ruby wrapper for the [JIRA](http://www.atlassian.com/JIRA)
[REST API](https://docs.atlassian.com/jira/REST/latest/), supporting Jira
versions 6.2 and up.

[Full documentation is on rdoc.info](http://rubydoc.info/github/a-e/jiraby/master/frames).

[![Build Status](https://secure.travis-ci.org/a-e/jiraby.png?branch=master)](http://travis-ci.org/a-e/jiraby)

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


Wrappers
--------

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


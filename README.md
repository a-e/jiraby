Jiraby
======

Jiraby is a Ruby wrapper for the [JIRA](http://www.atlassian.com/JIRA)
[REST API](https://docs.atlassian.com/jira/REST/latest/), supporting Jira
versions 6.2 and up.

[Full documentation is on rdoc.info](http://rubydoc.info/github/a-e/jiraby/master/frames).


Usage
-----

Assuming your JIRA site is at `http://jira.enterprise.com`, and you have
an account `picard` with password `earlgrey`, you can connect like so:

    require 'jiraby'

    jira = Jiraby::Jira.new('http://jira.enterprise.com')
    jira.login('picard', 'earlgrey')

You can provide a port number if needed:

    jira = Jiraby::Jira.new('http://jira.enterprise.com:8080')

Look up an issue by its key:

    issue = jira.issue('myproj-15')
    issue = jira.issue('MYPROJ-15') # case-insensitive

Use `[]` and `[]=` to view or modify issue fields:

    issue['summary']
    => "Sample issue"

    issue['summary'] = "Modified summary"

    issue['summary']
    => "Modified summary"

See what fields were updated and need to be saved:

    issue.modified?
    => true

    issue.updates
    => {"summary" => "Modified summary"}

Save the updates back to Jira:

    issue.save!
    => true

Or view the raw data returned from Jira's REST API:

    issue.data
    => {
      'id' => '10024',
      'key' => 'MYPROJ-15',
      'self' => 'http://jira.enterprise.com:8080/rest/api/2/issue/10024',
      'fields' => {
        'summary' => 'Realign the dilithium stabilizer matrix.',
        ...
      }
    }

See a list of field IDs, including any project-specific or other custom fields:

    issue.field_ids
    => [
      "assignee",
      "attachment",
      "comment",
      "customfield_10000",
      ...
    ]


REST API
--------

Methods in the [JIRA REST API](https://docs.atlassian.com/jira/REST/6.2/) can be
accessed directly:

    jira.get('issue/TEST-1')
    => {
      "id"=>"10000",
      "self"=>"http://localhost:8080/rest/api/2/issue/10000",
      "key"=>"TEST-1",
      "fields"=>{ ... }
    }

    jira.get('serverInfo')
    => {
      "baseUrl"=>"http://localhost:8080",
      "version"=>"6.2",
      "versionNumbers"=>[6, 2, 0],
      "buildNumber"=>6252,
      "buildDate"=>"2014-02-19T00:00:00.000-0700",
      "serverTime"=>"2014-03-06T08:27:04.116-0700",
      "scmInfo"=>"aa343257d4ce030d9cb8c531be520be9fac1c996",
      "serverTitle"=>"Jiraby Test"
    }

    jira.get('resolution/1')
    => {
      "self"=>"http://localhost:8080/rest/api/2/resolution/1",
      "id"=>"1",
      "description"=>"A fix for this issue is checked into the tree and tested.",
      "name"=>"Fixed"
    }

Passing parameters to GET:

    jira.get('user/search?username=admin')
    => [{"self"=>"http://localhost:8080/rest/api/2/user?username=admin",
      "key"=>"admin",
      "name"=>"admin",
      "emailAddress"=>"epierce@automation-excellence.com",
      "avatarUrls"=>
       {"16x16"=>
         "http://localhost:8080/secure/useravatar?size=xsmall&avatarId=10122",
        "24x24"=>
         "http://localhost:8080/secure/useravatar?size=small&avatarId=10122",
        "32x32"=>
         "http://localhost:8080/secure/useravatar?size=medium&avatarId=10122",
        "48x48"=>"http://localhost:8080/secure/useravatar?avatarId=10122"},
      "displayName"=>"Admin Istrator",
      "active"=>true,
      "timeZone"=>"America/Denver"}]


Copyright
---------

The MIT License

Copyright (c) 2011 Brian Moelk, Eric Pierce

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


Usage
=====

Assuming your JIRA site is at `http://jira.enterprise.com`, and you have
an account `picard` with password `earlgrey`, you can connect like so:

    require 'jiraby'

    jira = Jiraby::Jira.new('http://jira.enterprise.com')
    jira.login('picard', 'earlgrey')

Using Jiraby from the Ruby console:

    $ bundle console
    > require 'lib/jiraby/jira'
    > jira = Jiraby::Jira.new('http://localhost:8080')
    > jira.login('username', 'password')
    > jira.logout

Methods in the [JIRA REST API](https://docs.atlassian.com/jira/REST/6.2/) can be
accessed like so:

    > jira.get('issue/TEST-1')
    => {"id"=>"10000",
     "self"=>"http://localhost:8080/rest/api/2/issue/10000",
     "key"=>"TEST-1",
     "fields"=>{ ... }
     }

    > jira.get('serverInfo')
    => {"baseUrl"=>"http://localhost:8080",
     "version"=>"6.2",
     "versionNumbers"=>[6, 2, 0],
     "buildNumber"=>6252,
     "buildDate"=>"2014-02-19T00:00:00.000-0700",
     "serverTime"=>"2014-03-06T08:27:04.116-0700",
     "scmInfo"=>"aa343257d4ce030d9cb8c531be520be9fac1c996",
     "serverTitle"=>"Jiraby Test"}

    > jira.get('resolution/1')
    => {"self"=>"http://localhost:8080/rest/api/2/resolution/1",
     "id"=>"1",
     "description"=>"A fix for this issue is checked into the tree and tested.",
     "name"=>"Fixed"}

Passing parameters to GET:

    > jira.get('user/search?username=admin')
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


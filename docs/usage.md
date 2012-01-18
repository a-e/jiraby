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
    > jira = Jiraby::Jira.new('http://localhost:8080', '2')
    > jira.login('username', 'password')
    > jira.logout

Accessing REST methods:

    > jira.get('serverInfo')
     => {
        "scmInfo"=>"167904",
        "buildNumber"=>710,
        "version"=>"5.0-rc2",
        "serverTime"=>"2011-12-21T09:37:12.550-0700",
        "versionNumbers"=>[5, 0, 0],
        "buildDate"=>"2011-12-01T00:00:00.000-0700",
        "serverTitle"=>"Jiraby Jira",
        "baseUrl"=>"http://localhost:8080"
      }

    > jira.get('resolution/1')
     => {
        "name"=>"Fixed",
        "self"=>"http://localhost:8080/rest/api/2/resolution/1",
        "id"=>"1",
        "description"=>"A fix for this issue is checked into the tree and tested."
      }

Passing parameters to GET:

    jira.get('user/search', {'username' => 'admin'})
    => [
      {
         "name"=>"admin",
         "self"=>"http://localhost:8080/rest/api/2/user?username=admin",
         "displayName"=>"Administrator",
         "timeZone"=>"America/Denver",
         "emailAddress"=>"epierce@automation-excellence.com",
         "avatarUrls"=>{"48x48"=>"http://localhost:8080/secure/useravatar?avatarId=10122",
         "16x16"=>"http://localhost:8080/secure/useravatar?size=small&avatarId=10122"},
         "active"=>true
      }
    ]


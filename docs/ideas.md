Jiraby API ideas
================

- Implement an attribute wrapper for hashes, to allow stuff like:
    issue.project.key
    issue.project.owner
    (See http://pullmonkey.com/2008/01/06/convert-a-ruby-hash-into-a-class-object/)

Issue fields have different types. For example:

    > iss.json['fields']['comment']
     => {"comments"=>[], "startAt"=>0, "total"=>0, "maxResults"=>0}

    > iss.json['fields']['environment']
     => nil

    > iss.json['fields']['summary']
     => "It's broken"

    > iss.json['fields']['subtasks']
     => []

Further, these are different in different versions of Jira. The above are from
Jira 5.0, while Jira 4.4 produces:

    > iss.json['fields']['comment']
     => {"name"=>"comment", "value"=>[], "type"=>"com.atlassian.jira.issue.fields.CommentSystemField"}

    > iss.json['fields']['environment']
     => {"name"=>"environment", "type"=>"java.lang.String"}

    > iss.json['fields']['summary']
     => {"name"=>"summary", "value"=>"Cherwell incident #33170", "type"=>"java.lang.String"}

    > iss.json['fields']['sub-tasks'] # NOTE: Different key
     => {"name"=>"sub-tasks", "value"=>[], "type"=>"issuelinks"}

Maintaining compatibility between both of these could be a royal pain. It's
probably best to separate the REST / JSON stuff from the specific Jira/API
version we're using.

Consistency
-----------

The JIRA REST API is consistent in some things:

  - It (almost) always returns JSON
    Note: At least one method (PUT /issue/<key>) returns an empty string on success
  - Use of `self` for each entity

Challenges:

  - How to remain authenticated (pass JSONResource around to each REST request)?


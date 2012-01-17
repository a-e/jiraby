JIRA_2_ISSUE = {
  "key" => "TST-1",
  "id" => "10000",
  "self" => "http://localhost:8080/rest/api/2/issue/10000",
  "expand" => "renderedFields,names,schema,transitions,editmeta,changelog",
  "fields" => {
    "comment" => {"comments" => [], "startAt" => 0, "total" => 0, "maxResults" => 0},
    "aggregatetimeestimate" => 60,
    "watches" => {
      "self" => "http://localhost:8080/rest/api/2/issue/TST-1/watchers",
      "watchCount" => 0,
      "isWatching" => false,
    },
    "votes" => {
      "votes" => 0,
      "self" => "http://localhost:8080/rest/api/2/issue/TST-1/votes",
      "hasVoted" => false,
    },
    "timeestimate" => 60,
    "reporter" => {
      "name" => "epierce",
      "self" => "http://localhost:8080/rest/api/2/user?username=epierce",
      "displayName" => "Eric Pierce",
      "emailAddress" => "epierce@automation-excellence.com",
      "avatarUrls" => {
        "48x48" => "http://localhost:8080/secure/useravatar?avatarId=10122",
        "16x16" => "http://localhost:8080/secure/useravatar?size=small&avatarId=10122",
      },
      "active" => true,
    },
    "resolution" => nil,
    "aggregatetimespent" => nil,
    "components" => [],
    "issuelinks" => [],
    "aggregateprogress" => {"total" => 60, "progress" => 0, "percent" => 0},
    "attachment" => [],
    "timespent" => nil,
    "priority" => {
      "name" => "Major",
      "iconUrl" => "http://localhost:8080/images/icons/priority_major.gif",
      "self" => "http://localhost:8080/rest/api/2/priority/3",
      "id" => "3",
    },
    "progress" => {"total" => 60, "progress" => 0, "percent" => 0},
    "project" => {
      "name" => "Test",
      "self" => "http://localhost:8080/rest/api/2/project/TST",
      "id" => "10000",
      "avatarUrls" => {
        "48x48" => "http://localhost:8080/secure/projectavatar?pid=10000&avatarId=10011",
        "16x16" => "http://localhost:8080/secure/projectavatar?size=small&pid=10000&avatarId=10011",
      },
      "key" => "TST",
    },
    "subtasks" => [],
    "aggregatetimeoriginalestimate" => 60,
    "assignee" => {
      "name" => "admin",
      "self" => "http://localhost:8080/rest/api/2/user?username=admin",
      "displayName" => "Administrator",
      "emailAddress" => "epierce@automation-excellence.com",
      "avatarUrls" => {
        "48x48" => "http://localhost:8080/secure/useravatar?avatarId=10122",
        "16x16" => "http://localhost:8080/secure/useravatar?size=small&avatarId=10122",
      },
      "active" => true,
    },
    "workratio" => 0,
    "duedate" => nil,
    "resolutiondate" => nil,
    "timetracking" => {"originalEstimate" => "1m", "remainingEstimate" => "1m"},
    "versions" => [],
    "fixVersions" => [],
    "timeoriginalestimate" => 60,
    "environment" => nil,
    "worklog" => {"startAt" => 0, "worklogs" => [], "total" => 0, "maxResults" => 0},
    "description" => "We need a new foo widget",
    "summary" => "New widget",
    "labels" => [],
    "status" => {
      "name" => "Open",
      "iconUrl" => "http://localhost:8080/images/icons/status_open.gif",
      "self" => "http://localhost:8080/rest/api/2/status/1",
      "id" => "1",
      "description" => "The issue is open and ready for the assignee to start work on it.",
    },
    "updated" => "2011-12-21T11:36:12.145-0700",
    "created" => "2011-12-21T11:36:12.145-0700",
    "issuetype" => {
      "name" => "Bug",
      "iconUrl" => "http://localhost:8080/images/icons/bug.gif",
      "self" => "http://localhost:8080/rest/api/2/issuetype/1",
      "id" => "1",
      "subtask" => false,
      "description" => "A problem which impairs or prevents the functions of the product.",
    },
  },
}


JIRA_2_ALPHA_ISSUE = {
  "key" => "TST-1",
  "self" => "http://localhost:8080/rest/api/2.0.alpha1/issue/TST-1",
  "transitions" => "http://localhost:8080/rest/api/2.0.alpha1/issue/TST-1/transitions",
  "expand" => "html",
  "fields" => {
    "comment" => {
      "name" => "comment",
      "type" => "com.atlassian.jira.issue.fields.CommentSystemField",
      "value" => [],
    },
    "customfield_10040" => {
      "name" => "Flagged",
      "type" => "com.atlassian.jira.plugin.system.customfieldtypes:multicheckboxes",
    },
    "reporter" => {
      "name" => "reporter",
      "type" => "com.opensymphony.user.User",
      "value" => {
        "name" => "epierce",
        "self" => "http://localhost:8080/rest/api/2.0.alpha1/user?username=epierce",
        "displayName" => "Pierce, Eric",
        "active" => true,
      },
    },
    "security" => {
      "name" => "security",
      "type" => "com.atlassian.jira.issue.security.IssueSecurityLevel",
    },
    "attachment" => {
      "name" => "attachment",
      "value" => [],
      "type" => "attachment",
    },
    "priority" => {
      "name" => "priority",
      "type" => "com.atlassian.jira.issue.priority.Priority",
      "value" => {
        "name" => "Major",
        "self" => "http://localhost:8080/rest/api/2.0.alpha1/priority/3",
      },
    },
    "project" => {
      "name" => "project",
      "type" => "com.atlassian.jira.project.Project",
      "value" => {
        "name" => "SHRM Test",
        "self" => "http://localhost:8080/rest/api/2.0.alpha1/project/TST",
        "roles" => {},
        "key" => "TST",
      },
    },
    "sub-tasks" => {
      "name" => "sub-tasks",
      "value" => [
        {
          "type" => {
            "name" => "Sub-Task",
            "direction" => "OUTBOUND",
          },
          "issue" => "http://localhost:8080/rest/api/2.0.alpha1/issue/TST-4",
          "issueKey" => "TST-4",
        },
        {
          "type" => {
            "name" => "Sub-Task",
            "direction" => "OUTBOUND",
          },
          "issue" => "http://localhost:8080/rest/api/2.0.alpha1/issue/TST-5",
          "issueKey" => "TST-5",
        },
      ],
      "type" => "issuelinks",
    },
   "assignee" => {
      "name" => "assignee",
      "type" => "com.opensymphony.user.User",
      "value" => {
        "name" => "epierce",
        "self" => "http://localhost:8080/rest/api/2.0.alpha1/user?username=epierce",
        "displayName" => "Pierce, Eric",
        "active" => true,
      },
    },
    "duedate" => {
      "name" => "duedate",
      "type" => "java.util.Date",
    },
    "timetracking" => {
      "name" => "timetracking",
      "type" => "com.atlassian.jira.issue.fields.TimeTrackingSystemField",
    },
    "links" => {
      "name" => "links",
      "value" => [],
      "type" => "issuelinks",
    },
    "fixVersions" => {
      "name" => "fixVersions",
      "type" => "com.atlassian.jira.project.version.Version",
      "value" => [],
    },
    "environment" => {
      "name" => "environment",
      "type" => "java.lang.String",
    },
    "worklog" => {
      "name" => "worklog",
      "type" => "worklog",
      "value" => [],
    },
    "description" => {
      "name" => "description",
      "type" => "java.lang.String",
      "value" => "We need a new foo widget",
    },
    "summary" => {
      "name" => "summary",
      "type" => "java.lang.String",
      "value" => "New widget",
    },
    "labels" => {
      "name" => "labels",
      "type" => "com.atlassian.jira.issue.label.Label",
      "value" => [],
    },
    "status" => {
      "name" => "status",
      "type" => "com.atlassian.jira.issue.status.Status",
      "value" => {
        "name" => "Open",
        "self" => "http://localhost:8080/rest/api/2.0.alpha1/status/1",
      },
    },
    "updated" => {
      "name" => "updated",
      "type" => "java.util.Date",
      "value" => "2010-12-06T15:31:33.015-0500",
    },
    "watcher" => {
      "name" => "watcher",
      "type" => "watcher",
      "value" => {
        "self" => "http://localhost:8080/rest/api/2.0.alpha1/issue/TST-1/watchers",
        "watchCount" => 0,
        "isWatching" => false,
      },
    },
    "created" => {
      "name" => "created",
      "type" => "java.util.Date",
      "value" => "2010-12-06T15:22:05.461-0500",
    },
    "issuetype" => {
      "name" => "issuetype",
      "type" => "com.atlassian.jira.issue.issuetype.IssueType",
      "value" => {
        "name" => "Task",
        "self" => "http://localhost:8080/rest/api/2.0.alpha1/issueType/3",
        "subtask" => false,
      },
    },
  },
}


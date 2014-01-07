JIRA_2_PROJECT = {
  "key" => "TST",
  "name" => "Test",
  "id" => "10000",
  "self" => "http://localhost:8080/rest/api/2/project/TST",
  "assigneeType" => "PROJECT_LEAD",
  "components" => [],
  "versions" => [],
  "issueTypes" => [
    {
      "name" => "Bug",
      "iconUrl" => "http://localhost:8080/images/icons/bug.gif",
      "self" => "http://localhost:8080/rest/api/2/issuetype/1",
      "id" => "1",
      "subtask" => false,
      "description" => "A problem which impairs or prevents the functions of the product.",
    },
    {
      "name" => "New Feature",
      "iconUrl" => "http://localhost:8080/images/icons/newfeature.gif",
      "self" => "http://localhost:8080/rest/api/2/issuetype/2",
      "id" => "2",
      "subtask" => false,
      "description" => "A new feature of the product, which has yet to be developed.",
    },
    {
      "name" => "Task",
      "iconUrl" => "http://localhost:8080/images/icons/task.gif",
      "self" => "http://localhost:8080/rest/api/2/issuetype/3",
      "id" => "3",
      "subtask" => false,
      "description" => "A task that needs to be done.",
    },
    {
      "name" => "Improvement",
      "iconUrl" => "http://localhost:8080/images/icons/improvement.gif",
      "self" => "http://localhost:8080/rest/api/2/issuetype/4",
      "id" => "4",
      "subtask" => false,
      "description" => "An improvement or enhancement to an existing feature or task.",
    },
    {
      "name" => "Sub-task",
      "iconUrl" => "http://localhost:8080/images/icons/issue_subtask.gif",
      "self" => "http://localhost:8080/rest/api/2/issuetype/5",
      "id" => "5",
      "subtask" => true,
      "description" => "The sub-task of the issue",
    },
  ],
  "avatarUrls" => {
    "48x48" => "http://localhost:8080/secure/projectavatar?pid=10000&avatarId=10011",
    "16x16" => "http://localhost:8080/secure/projectavatar?size=small&pid=10000&avatarId=10011",
  },
  "roles" => {
    "Developers" => "http://localhost:8080/rest/api/2/project/TST/role/10001",
    "Administrators" => "http://localhost:8080/rest/api/2/project/TST/role/10002",
    "Users" => "http://localhost:8080/rest/api/2/project/TST/role/10000",
  },
  "lead" => {
    "name" => "admin",
    "self" => "http://localhost:8080/rest/api/2/user?username=admin",
    "displayName" => "Administrator",
    "active" => true,
    "avatarUrls" => {
      "48x48" => "http://localhost:8080/secure/useravatar?avatarId=10122",
      "16x16" => "http://localhost:8080/secure/useravatar?size=small&avatarId=10122",
    },
  },
}

JIRA_2_ALPHA_PROJECT = {
  "key" => "TST",
  "name" => "Test",
  "self" => "http://localhost:8080/rest/api/2.0.alpha1/project/TST",
  "assigneeType" => "PROJECT_LEAD",
  "components" => [],
  "versions" => [],
  "issueTypes" => [
    {
      "name" => "Bug",
      "self" => "http://localhost:8080/rest/api/2.0.alpha1/issueType/1",
      "subtask" => false,
    },
    {
      "name" => "New Feature",
      "self" => "http://localhost:8080/rest/api/2.0.alpha1/issueType/2",
      "subtask" => false,
    },
    {
      "name" => "Task",
      "self" => "http://localhost:8080/rest/api/2.0.alpha1/issueType/3",
      "subtask" => false,
    },
    {
      "name" => "Improvement",
      "self" => "http://localhost:8080/rest/api/2.0.alpha1/issueType/4",
      "subtask" => false,
    },
    {
      "name" => "Sub-task",
      "self" => "http://localhost:8080/rest/api/2.0.alpha1/issueType/5",
      "subtask" => true,
    },
  ],
  "roles" => {
    "Developers" => "http://localhost:8080/rest/api/2.0.alpha1/project/TST/role/10001",
    "Administrators" => "http://localhost:8080/rest/api/2.0.alpha1/project/TST/role/10002",
    "Users" => "http://localhost:8080/rest/api/2.0.alpha1/project/TST/role/10000",
  },
  "lead" => {
    "name" => "admin",
    "self" => "http://localhost:8080/rest/api/2.0.alpha1/user?username=admin",
    "displayName" => "Administrator",
    "active" => true,
  },
}

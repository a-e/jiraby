module Jiraby
  class JirabyError < RuntimeError; end
  class ProjectNotFound < JirabyError; end
  class IssueNotFound < JirabyError; end
  class RestCallFailed < JirabyError; end
  class InvalidField < JirabyError; end
end # module Jiraby


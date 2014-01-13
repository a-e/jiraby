module Jiraby
  class JirabyError < RuntimeError; end
  class ProjectNotFound < JirabyError; end
  class IssueNotFound < JirabyError; end
  class RestPostFailed < JirabyError; end
  class RestGetFailed < JirabyError; end
end # module Jiraby


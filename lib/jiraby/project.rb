module Jiraby
  class Project
    def initialize(json)
      @json = json
    end

    # Return a hash of issue types for the project, indexed by the name of the
    # issue type.
    #
    def issue_types
      # Index by issue type name
      result = {}
      @json['issueTypes'].each do |issue_type|
        result[issue_type['name']] = issue_type
      end
      return result
    end
  end
end


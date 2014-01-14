require 'hashie'

module Jiraby
  class Issue < Hashie::Mash
    # Return the value in the `key` field (Jira's issue identifier).
    def key(*args)
      # Pass-through to Hash's `key` method
      if args.length > 0
        super(*args)
      else
        return self['key']
      end
    end

    # Set the field named `name` equal to `value`.
    # `name` may be the field identifier (like `subtasks` or `customfield_10001`),
    # or it may be the human-readable field name (like `Sub-Tasks` or `My Custom Field`).
    #
    def set(name, value)
      # TODO: In order to implement this, the Issue class will need access to
      # Jira's field name mappings (`Jiraby::Jira#fields`)
    end
  end
end

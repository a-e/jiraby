require 'hashie'

module Jiraby
  # Represents some data structure in Jira, as it would be returned by
  # a REST API method.
  class Entity < Hashie::Mash
    # If no `args` are given, return the value in the `key` field (often used
    # as an identifier in Jira). If `args` are given, pass-through to Hash's
    # regular `key` method (returning the key for a given value).
    def key(*args)
      # Pass-through to Hash's `key` method
      if args.length > 0
        super(*args)
      else
        return self['key']
      end
    end

  end # class Entity
end # module Jiraby


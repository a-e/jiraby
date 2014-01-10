require 'hashie'

module Jiraby
  class Issue < Hashie::Mash
    # Work around Hash's builtin `key` method, since Jira issues use `key` for
    # their ID.
    def key
      return self['key']
    end
  end
end

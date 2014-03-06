require 'jiraby/entity'

module Jiraby
  class Issue < Entity
    # FIXME: Using a classmethod "constructor" is just a roundabout way to set
    # the `rest` attribute (overriding `#initialize(rest, data)` does not seem
    # to work with nested hashes and Hashie::Mash).
    def self.from_json(json_resource, json_data)
      issue = self.new(json_data)
      issue.rest = json_resource
      return issue
    end
    attr_accessor :rest

    # Set the field named `name` equal to `value`.
    # `name` may be the field identifier (like `subtasks` or `customfield_10001`),
    # or it may be the human-readable field name (like `Sub-Tasks` or `My Custom Field`).
    #
    def set(name, value)
      # TODO: In order to implement this, the Issue class will need access to
      # Jira's field name mappings (`Jiraby::Jira#fields`)
    end

    def editmeta
      @rest["issue/#{self['id']}/editmeta"].get
    end

    # Return all fields that are editable ("set"table)
    def settable_fields
      editable = self.editmeta['fields']
      return self['fields'].select do |key, value|
        editable.keys.include?(key) && \
          editable[key]['operations'].include?('set') && \
          !value.nil? && !value.empty?
      end
    end

    # Save this issue by sending a PUT request
    def save
      data = {'fields' => self.settable_fields}
      @rest["issue/#{self['id']}"].put data.to_json
    end
  end
end

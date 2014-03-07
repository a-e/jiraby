require 'jiraby/entity'

module Jiraby
  class Issue
    def initialize(jira_instance, json_data={})
      @jira = jira_instance
      @data = Entity.new(json_data)
      # Modifications are stored here until #save is called
      @updates = Entity.new
    end

    attr_reader :jira, :data, :updates

    # Return this issue's `key`
    def key
      return @data.key
    end

    # Set field `name_or_id` equal to `value`.
    def []=(name_or_id, value)
      @updates[self.field_id(name_or_id)] = value
    end

    # Return the value in field `name_or_id`.
    def [](name_or_id)
      _id = self.field_id(name_or_id)
      return @updates[_id] || @data.fields[_id]
    end

    # Return a field ID, given a name or ID. `name_or_id` may be the field's ID
    # (like "subtasks" or "customfield_10001"), or it may be the human-readable
    # field name (like "Sub-Tasks" or "My Custom Field").
    #
    # TODO: Raise an exception on invalid name_or_id?
    def field_id(name_or_id)
      if @data.fields.include?(name_or_id)
        return name_or_id
      else
        _id = @jira.field_mapping.key(name_or_id)
        if _id.nil?
          raise RuntimeError.new("Invalid field name or ID: #{name_or_id}")
        end
        return _id
      end
    end

    def editmeta
      @jira.get("issue/#{@data.key}/editmeta")
    end

    # Return true if this issue has been modified since saving.
    def modified?
      !@updates.empty?
    end

    # Save this issue by sending a PUT request.
    # Return true if save was successful.
    def save
      json_data = {'fields' => @updates}
      @jira.put("issue/#{@data.key}", json_data)
      @updates = Entity.new
      return true
    end
  end
end

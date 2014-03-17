require 'jiraby/exceptions'
require 'jiraby/entity'

module Jiraby
  class Issue
    def initialize(jira_instance, json_data={})
      @jira = jira_instance
      @data = Entity.new(json_data)
      # Modifications are stored here until #save is called
      @pending_changes = Entity.new
    end

    attr_reader :jira, :data, :pending_changes

    # Return this issue's `key`
    def key
      return @data.key
    end

    # Set field `name_or_id` equal to `value`.
    def []=(name_or_id, value)
      @pending_changes[self.field_id(name_or_id)] = value
    end

    # Return the value in field `name_or_id`.
    def [](name_or_id)
      _id = self.field_id(name_or_id)
      return @pending_changes[_id] || @data.fields[_id]
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
          raise InvalidField.new("Invalid field name or ID: #{name_or_id}")
        end
        return _id
      end
    end

    # Return true if this issue has a field with the given name or ID,
    # false otherwise.
    def has_field?(name_or_id)
      begin
        self.field_id(name_or_id)
      rescue InvalidField
        return false
      else
        return true
      end
    end

    # Return true if this issue is a subtask, false otherwise.
    def is_subtask?
      return @data.fields.issuetype.subtask
    end

    # Return true if this issue is assigned to someone, false otherwise.
    def is_assigned?
      return !@data.fields.assignee.nil?
    end

    # Return this issue's parent key, or nil if this issue has no parent.
    def parent
      if is_subtask?
        return @data.fields.parent.key
      else
        return nil
      end
    end

    # Return this issue's subtask keys
    def subtasks
      return @data.fields.subtasks.collect { |st| st.key }
    end

    # Return a sorted list of valid field IDs for this issue.
    def field_ids
      return @data.fields.keys.sort
    end

    def editmeta
      return @jira.get("issue/#{@data.key}/editmeta")
    end

    # Return true if this issue has been modified since saving.
    def pending_changes?
      return !@pending_changes.empty?
    end

    # Save this issue by sending a PUT request.
    # Return true if save was successful.
    def save!
      json_data = {'fields' => @pending_changes}
      # TODO: Handle failed save
      @jira.put("issue/#{@data.key}", json_data)
      @data.fields.merge!(@pending_changes)
      @pending_changes = Entity.new
      return true
    end
  end
end

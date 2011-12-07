module Jiraby
  class Issue
    attr_reader :json

    # Create an Issue from the given JSON structure,
    # as returned by the `issue/issueKey` REST API
    def initialize(json)
      @json = json
    end

    # Return the key identifier for this issue
    def key
      @json['key']
    end

    # Return all field names in this issue
    def fields
      @json['fields'].keys
    end

    # Return the field name (label) for the given field
    def field_name(field)
      @json['fields'][field]['name']
    end

    # Allow directly accessing field values as if they were attributes
    def method_missing(meth, *args, &block)
      if @json['fields'].keys.include?(meth.to_s)
        return @json['fields'][meth.to_s]['value']
      else
        super
      end
    end
  end
end

# app/serializers/api/base_serializer.rb

module Api
  # Base serializer for JSON output with support for regular and computed attributes
  class BaseSerializer
    # Configuration methods for defining serializable attributes
    class << self
      # Define which model attributes to include in serialized output
      def attributes(*names)
        @_attributes ||= []
        @_attributes.concat(names.map(&:to_sym))
      end

      # Define computed attributes calculated at serialization time
      def attribute(name, &block)
        @_computed ||= {}
        @_computed[name.to_sym] = block
      end

      # Accessors for configured attributes
      def attribute_names
        (@_attributes || [])
      end

      def computed_attributes
        (@_computed   || {})
      end
    end

    # Initialize with record/collection and optional context
    def initialize(record_or_collection, context: {})
      @record_or_collection = record_or_collection
      @context = context || {}
    end

    # Main serialization entry point - handles both single records and collections
    def as_json(*)
      return [] if @record_or_collection.nil?
      return serialize_collection if @record_or_collection.respond_to?(:to_ary)
      serialize_one(@record_or_collection)
    end

    private

    attr_reader :context

    # Serialize a collection of records
    def serialize_collection
      @record_or_collection.map { |record| serialize_one(record) }
    end

    # Serialize a single record by combining regular and computed attributes
    def serialize_one(record)
      payload = {}
      add_regular_attributes(payload, record)
      add_computed_attributes(payload, record)
      payload
    end

    # Add model attributes directly to payload
    def add_regular_attributes(payload, record)
      self.class.attribute_names.each { |attr| payload[attr] = record.public_send(attr) }
    end

    # Add computed attributes by executing their blocks
    def add_computed_attributes(payload, record)
      self.class.computed_attributes.each do |attr, block|
        payload[attr] = instance_exec(record, &block)
      end
    end
  end
end

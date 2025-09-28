module Api
  class BaseSerializer
    class << self
      def attributes(*names)
        @_attributes ||= []
        @_attributes.concat(names.map(&:to_sym))
      end

      def attribute(name, &block)
        @_computed ||= {}
        @_computed[name.to_sym] = block
      end

      def attribute_names
        @_attributes || []
      end

      def computed_attributes
        @_computed || {}
      end
    end

    def initialize(record_or_collection, context: {})
      @record_or_collection = record_or_collection
      @context = context
    end

    def as_json(*)
      return [] if @record_or_collection.nil?
      return serialize_collection if @record_or_collection.respond_to?(:to_ary)
      serialize_one(@record_or_collection)
    end

    private

    def serialize_collection
      @record_or_collection.map { |record| serialize_one(record) }
    end

    def serialize_one(record)
      payload = {}
      add_regular_attributes(payload, record)
      add_computed_attributes(payload, record)
      payload
    end

    def add_regular_attributes(payload, record)
      self.class.attribute_names.each do |attr|
        payload[attr] = record.public_send(attr)
      end
    end

    def add_computed_attributes(payload, record)
      self.class.computed_attributes.each do |attr, block|
        payload[attr] = instance_exec(record, &block)
      end
    end
  end
end

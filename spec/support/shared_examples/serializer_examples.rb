# frozen_string_literal: true

RSpec.shared_examples "a collection serializer" do |serializer_class:, factory:, expected_keys:|
    it "serializes a collection with expected keys" do
      records = create_list(factory, 2)
      payload = serializer_class.new(records).as_json
      expect(payload).to be_an(Array)
      expect(payload.first.keys.map!(&:to_s)).to include(*expected_keys.map!(&:to_s))
    end
end

RSpec.shared_examples "a resource serializer" do |serializer_class:, factory:, expected_keys:|
    it "serializes a single resource with expected keys" do
      record  = create(factory)
      payload = serializer_class.new(record).as_json
      expect(payload).to be_a(Hash)
      expect(payload.keys.map!(&:to_s)).to include(*expected_keys.map!(&:to_s))
    end
end

# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::MenuCollectionSerializer do
  it_behaves_like "a collection serializer",
                  serializer_class: described_class,
                  factory: :menu,
                  expected_keys: %i[id name active starts_at ends_at status]
end

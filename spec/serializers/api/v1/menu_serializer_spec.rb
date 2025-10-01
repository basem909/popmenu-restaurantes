# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::MenuSerializer do
  it_behaves_like "a resource serializer",
                  serializer_class: described_class,
                  factory: :menu,
                  expected_keys: %i[id name description active starts_at ends_at status]
end

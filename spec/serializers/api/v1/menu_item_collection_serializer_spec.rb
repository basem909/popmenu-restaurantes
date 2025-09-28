# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::MenuItemCollectionSerializer do
  it_behaves_like "a collection serializer",
                  serializer_class: described_class,
                  factory: :menu_item,
                  expected_keys: %i[id name price currency active display_price]
end

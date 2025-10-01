
require "rails_helper"

RSpec.describe Api::V1::MenuItemSerializer do
  it_behaves_like "a resource serializer",
                  serializer_class: described_class,
                  factory: :menu_item,
                  expected_keys: %i[id name description price currency active display_price]
end

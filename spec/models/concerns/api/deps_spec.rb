# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::Deps do
  it "returns collection/resource serializers for Menu" do
    expect(described_class.serializer_for(Menu, :collection)).to eq(Api::V1::MenuCollectionSerializer)
    expect(described_class.serializer_for(Menu, :resource)).to   eq(Api::V1::MenuSerializer)
  end

  it "returns collection/resource serializers for MenuItem" do
    expect(described_class.serializer_for(MenuItem, :collection)).to eq(Api::V1::MenuItemCollectionSerializer)
    expect(described_class.serializer_for(MenuItem, :resource)).to   eq(Api::V1::MenuItemSerializer)
  end

  it "raises on unknown model" do
    stub_const("Ghost", Class.new)
    expect { described_class.serializer_for(Ghost, :collection) }.to raise_error(KeyError)
  end

  it "raises on unknown kind" do
    expect { described_class.serializer_for(Menu, :foobar) }.to raise_error(KeyError)
  end
end

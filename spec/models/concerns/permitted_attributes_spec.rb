# frozen_string_literal: true

require "rails_helper"

RSpec.describe PermittedAttributes do
  it "returns menu attributes" do
    attrs = described_class.for("menu")
    expect(attrs).to include(:name, :description, :active, :starts_at, :ends_at)
  end

  it "returns menu_item attributes" do
    attrs = described_class.for("menu_item")
    expect(attrs).to include(:name, :description, :price, :currency, :active)
  end

  it "returns [] for unknown resource" do
    expect(described_class.for("unknown")).to eq([])
  end
end

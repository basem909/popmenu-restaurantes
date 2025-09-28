# frozen_string_literal: true

require "rails_helper"

RSpec.describe MenuItem, type: :model do
  describe "validations" do
    it "requires name" do
      record = described_class.new(price: 1)
      expect(record).not_to be_valid
      expect(record.errors[:name]).to be_present
    end

    it "requires non-negative price" do
      record = described_class.new(name: "X", price: -1)
      expect(record).not_to be_valid
      expect(record.errors[:price]).to be_present
    end
  end

  describe "associations" do
    it "belongs to menu" do
      reflection = described_class.reflect_on_association(:menu)
      expect(reflection.macro).to eq(:belongs_to)
    end
  end

  describe ".active" do
    it "returns only active items" do
      create(:menu_item, active: true)
      create(:menu_item, active: false)
      expect(described_class.active.count).to eq(1)
    end
  end
end

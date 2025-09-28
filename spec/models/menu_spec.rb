# frozen_string_literal: true

require "rails_helper"

RSpec.describe Menu, type: :model do
  describe "validations" do
    it "requires name" do
      record = described_class.new
      expect(record).not_to be_valid
      expect(record.errors[:name]).to be_present
    end
  end

  describe "associations" do
    it "has many menu_items" do
      reflection = described_class.reflect_on_association(:menu_items)
      expect(reflection.macro).to eq(:has_many)
    end
  end

  describe ".active" do
    it "returns only active records" do
      create(:menu, active: true)
      create(:menu, active: false)
      expect(described_class.active.count).to eq(1)
    end
  end
end

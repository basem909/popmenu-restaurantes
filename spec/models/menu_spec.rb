# frozen_string_literal: true

require "rails_helper"

RSpec.describe Menu, type: :model do
  subject(:menu) { build(:menu) }

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:restaurant) }
    it { is_expected.to have_many(:menu_itemizations).dependent(:destroy) }
    it { is_expected.to have_many(:menu_items).through(:menu_itemizations) }
  end

  describe ".active" do
    it "returns only menus that are currently available" do
      active  = create(:menu, active: true)
      inactive = create(:menu, active: false)

      expect(described_class.active).to contain_exactly(active)
    end
  end

  describe "defaults" do
    it "defaults to active" do
      expect(menu.active).to be(true)
    end
  end
end

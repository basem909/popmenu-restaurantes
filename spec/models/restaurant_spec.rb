# frozen_string_literal: true

require "rails_helper"

RSpec.describe Restaurant, type: :model do
  describe "factory" do
    it "is valid" do
      expect(build(:restaurant)).to be_valid
    end
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
  end

  describe "associations" do
    it { is_expected.to have_many(:menus) }
    it { is_expected.to have_many(:menu_items) }

    it { is_expected.to have_many(:menus).dependent(:destroy) }
    it { is_expected.to have_many(:menu_items).dependent(:destroy) }
  end

  describe "persistence / identifiers" do
    it "uses a UUID primary key" do
      restaurant = create(:restaurant)
      expect(restaurant.id).to be_present
      expect(restaurant.id).to match(/\A[0-9a-fA-F-]{36}\z/)
    end
  end


  describe "database columns" do
    it { is_expected.to have_db_column(:id).of_type(:uuid) }
    it { is_expected.to have_db_column(:name).of_type(:string) }
    it { is_expected.to have_db_column(:created_at).of_type(:datetime) }
    it { is_expected.to have_db_column(:updated_at).of_type(:datetime) }
  end
end

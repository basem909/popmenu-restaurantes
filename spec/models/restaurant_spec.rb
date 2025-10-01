# frozen_string_literal: true

require "rails_helper"

RSpec.describe Restaurant, type: :model do
  describe "factories" do
    it "builds the default restaurant" do
      expect(build(:restaurant)).to be_valid
    end
  end

  describe "validations" do
    subject { build(:restaurant) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name).case_insensitive }
  end

  describe "associations" do
    it { is_expected.to have_many(:menus).dependent(:destroy) }
    it { is_expected.to have_many(:menu_items).dependent(:destroy) }
  end

  describe "primary keys" do
    it "uses UUIDs" do
      restaurant = create(:restaurant)
      expect(restaurant.id).to match(/[0-9a-fA-F-]{36}/)
    end
  end

  describe "database columns" do
    it { is_expected.to have_db_column(:id).of_type(:uuid) }
    it { is_expected.to have_db_column(:name).of_type(:string) }
    it { is_expected.to have_db_column(:created_at).of_type(:datetime) }
    it { is_expected.to have_db_column(:updated_at).of_type(:datetime) }
  end
end

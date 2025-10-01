# frozen_string_literal: true

require "rails_helper"

RSpec.describe MenuItemization, type: :model do
  subject(:menu_itemization) { build(:menu_itemization) }

  describe "associations" do
    it { is_expected.to belong_to(:menu) }
    it { is_expected.to belong_to(:menu_item) }

    it "leaves the menu and item in place when the link is removed" do
      link = create(:menu_itemization)
      menu = link.menu
      item = link.menu_item

      expect { link.destroy }.to change(described_class, :count).by(-1)
      expect(Menu.exists?(menu.id)).to be(true)
      expect(MenuItem.exists?(item.id)).to be(true)
    end
  end

  describe "validations" do
    it { is_expected.to validate_numericality_of(:price_on_menu).is_greater_than_or_equal_to(0).allow_nil }

    it "keeps the menu + item pairing unique" do
      existing = create(:menu_itemization)
      dup = build(:menu_itemization, menu: existing.menu, menu_item: existing.menu_item)

      expect(dup).not_to be_valid
      expect(dup.errors[:menu_id]).to be_present
    end

    it "disallows cross-restaurant pairings" do
      menu = create(:menu)
      item = create(:menu_item)

      invalid_link = build(:menu_itemization, menu: menu, menu_item: item)
      expect(invalid_link).not_to be_valid
      expect(invalid_link.errors[:base]).to include("Menu and MenuItem must belong to the same restaurant")
    end

    it "allows the same item on multiple menus in the same restaurant" do
      restaurant = create(:restaurant)
      item       = create(:menu_item, restaurant: restaurant)
      breakfast  = create(:menu, restaurant: restaurant, name: "Breakfast")
      dinner     = create(:menu, restaurant: restaurant, name: "Dinner")

      create(:menu_itemization, menu: breakfast, menu_item: item)
      expect(build(:menu_itemization, menu: dinner, menu_item: item)).to be_valid
    end

    it "requires a currency whenever a custom price is provided" do
      link = build(:menu_itemization, price_on_menu: 9.5, currency_on_menu: nil)
      expect(link).not_to be_valid
      expect(link.errors[:currency_on_menu]).to include("can't be blank")
    end

    it "allows an unpriced link with no currency" do
      expect(menu_itemization).to be_valid
    end
  end

  describe "database safety nets" do
    it "exposes a unique index across menu and item ids" do
      index_names = ActiveRecord::Base.connection.indexes(:menu_itemizations).map(&:name)
      expect(index_names).to include("index_menu_itemizations_on_menu_and_item")
    end

    it "raises RecordNotUnique if a duplicate slips through the app layer",
       if: ActiveRecord::Base.connection.adapter_name =~ /postgres/i do
      link = create(:menu_itemization)
      now  = Time.current

      expect {
        MenuItemization.insert_all!([
          {
            id: SecureRandom.uuid,
            menu_id: link.menu_id,
            menu_item_id: link.menu_item_id,
            created_at: now,
            updated_at: now
          }
        ])
      }.to raise_error(ActiveRecord::RecordNotUnique)
    end
  end

  describe "factories" do
    it "build engaging default links" do
      expect(build(:menu_itemization)).to be_valid
    end

    it "supports priced links via the :priced trait" do
      expect(build(:menu_itemization, :priced)).to be_valid
    end
  end
end

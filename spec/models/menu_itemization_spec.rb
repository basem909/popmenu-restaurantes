# frozen_string_literal: true
require "rails_helper"

RSpec.describe MenuItemization, type: :model do
  # ---------------------------------------------------------------------------
  # Associations
  # ---------------------------------------------------------------------------
  describe "associations" do
    it { is_expected.to belong_to(:menu) }
    it { is_expected.to belong_to(:menu_item) }

    it "does not delete menu or item when the link is destroyed" do
      r   = create(:restaurant)
      m   = create(:menu, restaurant: r)
      i   = create(:menu_item, restaurant: r)
      link = create(:menu_itemization, menu: m, menu_item: i)

      expect { link.destroy }.to change(MenuItemization, :count).by(-1)
      expect(Menu.exists?(m.id)).to be(true)
      expect(MenuItem.exists?(i.id)).to be(true)
    end
  end

  # ---------------------------------------------------------------------------
  # Validations
  # ---------------------------------------------------------------------------
  describe "validations" do
    # NOTE: Shoulda uniqueness + UUID case normalization can be flaky.
    # Option A (keep it): uncomment the next line to appease the matcher.
    # it { is_expected.to validate_uniqueness_of(:menu_id).scoped_to(:menu_item_id).ignoring_case_sensitivity }
    #
    # Option B (recommended): rely on explicit example + DB-constraint spec (below).

    it "enforces uniqueness of the [menu_id, menu_item_id] pair" do
      r = create(:restaurant)
      m = create(:menu, restaurant: r)
      i = create(:menu_item, restaurant: r)

      create(:menu_itemization, menu: m, menu_item: i)
      dup = build(:menu_itemization, menu: m, menu_item: i)

      expect(dup).not_to be_valid
      expect(dup.errors[:menu_id]).to be_present.or be_any
    end

    it "rejects linking across restaurants (custom validation)" do
      r1 = create(:restaurant)
      r2 = create(:restaurant)
      m  = create(:menu, restaurant: r1)
      i  = create(:menu_item, restaurant: r2)

      link = build(:menu_itemization, menu: m, menu_item: i)
      expect(link).not_to be_valid
      expect(link.errors[:base]).to include("Menu and MenuItem must belong to the same restaurant")
    end

    it "accepts the same item linked to different menus in the SAME restaurant" do
      r  = create(:restaurant)
      i  = create(:menu_item, restaurant: r)
      m1 = create(:menu, restaurant: r, name: "Breakfast")
      m2 = create(:menu, restaurant: r, name: "Lunch")

      link1 = create(:menu_itemization, menu: m1, menu_item: i)
      link2 = build(:menu_itemization,  menu: m2, menu_item: i)

      expect(link1).to be_valid
      expect(link2).to be_valid
    end

    it "accepts different items on the same menu" do
      r  = create(:restaurant)
      m  = create(:menu, restaurant: r)
      i1 = create(:menu_item, restaurant: r)
      i2 = create(:menu_item, restaurant: r)

      link1 = create(:menu_itemization, menu: m, menu_item: i1)
      link2 = build(:menu_itemization,  menu: m, menu_item: i2)

      expect(link1).to be_valid
      expect(link2).to be_valid
    end

    it "requires currency_on_menu when price_on_menu is present (business rule)" do
      r = create(:restaurant)
      m = create(:menu, restaurant: r)
      i = create(:menu_item, restaurant: r)

      missing_curr = build(:menu_itemization, menu: m, menu_item: i, price_on_menu: 10.0, currency_on_menu: nil)
      with_curr    = build(:menu_itemization, menu: m, menu_item: i, price_on_menu: 10.0, currency_on_menu: "USD")

      expect(missing_curr).not_to be_valid
      expect(missing_curr.errors[:currency_on_menu]).to be_present
      expect(with_curr).to be_valid
    end

    it "allows unpriced link without currency_on_menu" do
      r = create(:restaurant)
      m = create(:menu, restaurant: r)
      i = create(:menu_item, restaurant: r)

      link = build(:menu_itemization, menu: m, menu_item: i, price_on_menu: nil, currency_on_menu: nil)
      expect(link).to be_valid
    end

    it "validates price_on_menu numerically (>= 0) when present" do
      r = create(:restaurant)
      m = create(:menu, restaurant: r)
      i = create(:menu_item, restaurant: r)

      neg = build(:menu_itemization, menu: m, menu_item: i, price_on_menu: -1, currency_on_menu: "USD")
      ok0 = build(:menu_itemization, menu: m, menu_item: i, price_on_menu: 0,  currency_on_menu: "USD")
      okn = build(:menu_itemization, menu: m, menu_item: i, price_on_menu: 12.34, currency_on_menu: "USD")

      expect(neg).not_to be_valid
      expect(ok0).to be_valid
      expect(okn).to be_valid
    end
  end

  # ---------------------------------------------------------------------------
  # Database constraints (safety & race protection)
  # ---------------------------------------------------------------------------
  describe "database constraints" do
    it "has a unique index on [menu_id, menu_item_id]" do
      idx_names = ActiveRecord::Base.connection.indexes(:menu_itemizations).map(&:name)
      expect(idx_names).to include("index_menu_itemizations_on_menu_and_item")
    end

    it "raises RecordNotUnique on duplicate insert (race safety)",
       if: ActiveRecord::Base.connection.adapter_name =~ /postgres/i do
      r  = create(:restaurant)
      m  = create(:menu, restaurant: r)
      i  = create(:menu_item, restaurant: r)
      now = Time.current

      MenuItemization.insert_all!([
        {
          id: SecureRandom.uuid,
          menu_id: m.id,
          menu_item_id: i.id,
          created_at: now,
          updated_at: now
        }
      ])

      expect {
        MenuItemization.insert_all!([
          {
            id: SecureRandom.uuid,
            menu_id: m.id,
            menu_item_id: i.id,
            created_at: now,
            updated_at: now
          }
        ])
      }.to raise_error(ActiveRecord::RecordNotUnique)
    end
  end

  # ---------------------------------------------------------------------------
  # Factory sanity
  # ---------------------------------------------------------------------------
  describe "factory" do
    it "builds a valid default link" do
      expect(build(:menu_itemization)).to be_valid
    end

    it "supports a priced link when the trait is used" do
      link = build(:menu_itemization, :priced)
      expect(link).to be_valid
    end
  end
end

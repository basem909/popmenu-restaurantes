# frozen_string_literal: true
require "rails_helper"

RSpec.describe MenuItem, type: :model do
  # ---------------------------------------------------------------------------
  # Associations
  # ---------------------------------------------------------------------------
  describe "associations" do
    it { is_expected.to belong_to(:restaurant) }
    it { is_expected.to have_many(:menu_itemizations).dependent(:destroy) }
    it { is_expected.to have_many(:menus).through(:menu_itemizations) }

    it "links to many menus through the join" do
      r   = create(:restaurant)
      m1  = create(:menu, restaurant: r, name: "Breakfast")
      m2  = create(:menu, restaurant: r, name: "Lunch")
      mi  = create(:menu_item, restaurant: r, name: "Pancakes")

      create(:menu_itemization, menu: m1, menu_item: mi)
      create(:menu_itemization, menu: m2, menu_item: mi)

      expect(mi.menus.map(&:id)).to match_array([m1.id, m2.id])
    end

    it "destroys dependent menu_itemizations but not menus" do
      r  = create(:restaurant)
      m  = create(:menu, restaurant: r)
      mi = create(:menu_item, restaurant: r)
      create(:menu_itemization, menu: m, menu_item: mi)

      expect { mi.destroy }.to change(MenuItemization, :count).by(-1)
      expect(Menu.exists?(m.id)).to be(true) # menu remains
    end
  end

  # ---------------------------------------------------------------------------
  # Validations
  # ---------------------------------------------------------------------------
  describe "validations" do
    subject { build(:menu_item) } # for Shoulda uniqueness

    it { is_expected.to validate_presence_of(:name) }

    it "requires non-negative price (zero is OK)" do
      r = create(:restaurant)

      negative = described_class.new(restaurant: r, name: "X", price: -1)
      expect(negative).not_to be_valid
      expect(negative.errors[:price]).to be_present

      zero_ok = described_class.new(restaurant: r, name: "Y", price: 0)
      zero_ok.validate
      expect(zero_ok.errors[:price]).to be_empty
    end

    it "defaults currency to USD at the DB level when omitted (Postgres only)",
       if: ActiveRecord::Base.connection.adapter_name =~ /postgres/i do
      r   = create(:restaurant)
      now = Time.current

      # Omit the :currency key entirely to let DB default kick in
      result = MenuItem.insert_all!([
        {
          id: SecureRandom.uuid,
          restaurant_id: r.id,
          name: "Z",
          price: 1,
          active: true,
          created_at: now,
          updated_at: now
        }
      ], returning: %w[id]).first

      mi = MenuItem.find(result["id"])
      expect(mi.currency).to eq("USD")
    end

    it "enforces case-insensitive uniqueness per restaurant" do
      r = create(:restaurant)
      create(:menu_item, restaurant: r, name: "burger")
      dup = build(:menu_item, restaurant: r, name: "BURGER")
      expect(dup).not_to be_valid
      expect(dup.errors[:name]).to be_present
    end

    it "allows the same name across different restaurants" do
      create(:menu_item, restaurant: create(:restaurant), name: "burger")
      ok = build(:menu_item, restaurant: create(:restaurant), name: "BURGER")
      expect(ok).to be_valid
    end
  end

  # ---------------------------------------------------------------------------
  # Scopes / query helpers
  # ---------------------------------------------------------------------------
  describe ".active" do
    it "returns only active items" do
      create(:menu_item, active: true)
      create(:menu_item, active: false)
      expect(described_class.active.pluck(:active).uniq).to eq([true])
    end

    it "defaults to active: true on create" do
      expect(create(:menu_item).active).to be(true)
    end
  end

  # ---------------------------------------------------------------------------
  # Database constraints (safety & race protection)
  # ---------------------------------------------------------------------------
  describe "database constraints (optional but strong)" do
    it "has the unique index on [restaurant_id, lower(name)]" do
      indexes = ActiveRecord::Base.connection.indexes(:menu_items)
      names   = indexes.map(&:name)
      expect(names).to include("index_menu_items_on_restaurant_and_lower_name")
    end

    it "raises on duplicate insert at the DB level (race safety)",
       if: ActiveRecord::Base.connection.adapter_name =~ /postgres/i do
      r = create(:restaurant)

      MenuItem.insert_all!([
        {
          id: SecureRandom.uuid,
          restaurant_id: r.id,
          name: "Burger",
          price: 1,
          currency: "USD",
          active: true,
          created_at: Time.current,
          updated_at: Time.current
        }
      ])

      expect {
        MenuItem.insert_all!([
          {
            id: SecureRandom.uuid,
            restaurant_id: r.id,
            name: "burger", # same logical name, different case
            price: 2,
            currency: "USD",
            active: true,
            created_at: Time.current,
            updated_at: Time.current
          }
        ])
      }.to raise_error(ActiveRecord::RecordNotUnique)
    end
  end

  # ---------------------------------------------------------------------------
  # Factory sanity
  # ---------------------------------------------------------------------------
  describe "factory" do
    it "builds a valid default record" do
      expect(build(:menu_item)).to be_valid
    end

    it "provides an :inactive variant" do
      expect(build(:menu_item, :inactive)).not_to be_active
    end
  end
end

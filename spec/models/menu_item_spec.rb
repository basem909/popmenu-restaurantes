require "rails_helper"

RSpec.describe MenuItem, type: :model do
  describe "associations" do
    it "belongs to a restaurant" do
      r  = create(:restaurant)
      mi = create(:menu_item, restaurant: r)
      expect(mi.restaurant).to eq(r)
    end

    it "has many menus through menu_itemizations" do
      r   = create(:restaurant)
      m1  = create(:menu, restaurant: r, name: "Breakfast")
      m2  = create(:menu, restaurant: r, name: "Lunch")
      mi  = create(:menu_item, restaurant: r, name: "Pancakes")
      # link via join model
      create(:menu_itemization, menu: m1, menu_item: mi)
      create(:menu_itemization, menu: m2, menu_item: mi)

      expect(mi.menus.map(&:id)).to match_array([ m1.id, m2.id ])
    end

    it "destroys dependent menu_itemizations but not menus" do
      r  = create(:restaurant)
      m  = create(:menu, restaurant: r)
      mi = create(:menu_item, restaurant: r)
      create(:menu_itemization, menu: m, menu_item: mi)

      expect { mi.destroy }.to change { MenuItemization.count }.by(-1)
      expect(Menu.exists?(m.id)).to be(true) # menu remains
    end
  end

  describe "validations" do
    it "requires name" do
      r  = create(:restaurant)
      mi = described_class.new(restaurant: r, price: 1)
      expect(mi).not_to be_valid
      expect(mi.errors[:name]).to be_present
    end

    it "requires non-negative price" do
      r  = create(:restaurant)
      mi = described_class.new(restaurant: r, name: "X", price: -1)
      expect(mi).not_to be_valid
      expect(mi.errors[:price]).to be_present

      ok = described_class.new(restaurant: r, name: "Y", price: 0)
      ok.validate
      expect(ok.errors[:price]).to be_empty
    end

    it "defaults currency to USD from the DB" do
      r  = create(:restaurant)
      mi = create(:menu_item, restaurant: r, name: "Z", price: 1)
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

  describe ".active" do
    it "returns only active items" do
      create(:menu_item, active: true)
      create(:menu_item, active: false)
      expect(described_class.active.pluck(:active).uniq).to eq([ true ])
    end
  end

  describe "database constraints (optional but strong)" do
    it "has the unique index on [restaurant_id, lower(name)]" do
      indexes = ActiveRecord::Base.connection.indexes(:menu_items)
      names   = indexes.map(&:name)
      expect(names).to include("index_menu_items_on_restaurant_and_lower_name")
    end

    it "raises on duplicate insert at the DB level (race safety)", if: ActiveRecord::Base.connection.adapter_name =~ /postgres/i do
      r = create(:restaurant)
      MenuItem.insert_all!([
        { id: SecureRandom.uuid, restaurant_id: r.id, name: "Burger", price: 1, currency: "USD", active: true, created_at: Time.current, updated_at: Time.current }
      ])

      expect {
        MenuItem.insert_all!([
          { id: SecureRandom.uuid, restaurant_id: r.id, name: "burger", price: 2, currency: "USD", active: true, created_at: Time.current, updated_at: Time.current }
        ])
      }.to raise_error(ActiveRecord::RecordNotUnique)
    end
  end
end

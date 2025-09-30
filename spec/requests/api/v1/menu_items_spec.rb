# frozen_string_literal: true

require "rails_helper"

RSpec.describe "API V1 — Menu Items (nested under Menus)", type: :request do
  # ---------------------------------------------------------------------------
  # Setup
  # ---------------------------------------------------------------------------
  let(:restaurant) { create(:restaurant) }
  let(:menu)       { create(:menu, restaurant: restaurant, name: "Breakfast") }

  # Helpers keep examples tidy and intention-revealing
  def items_path(r: restaurant, m: menu)
    "/api/v1/restaurants/#{r.id}/menus/#{m.id}/menu_items"
  end

  def item_path(item, r: restaurant, m: menu)
    "#{items_path(r:, m:)}/#{item.id}"
  end

  # Attach an item to a menu, optionally with a per-menu price/currency
  def link_item_to_menu(item, m: menu, price: nil, currency: nil)
    create(:menu_itemization,
           menu: m, menu_item: item,
           price_on_menu: price, currency_on_menu: currency)
  end

  # ---------------------------------------------------------------------------
  # Index
  # ---------------------------------------------------------------------------
  describe "GET /api/v1/restaurants/:restaurant_id/menus/:menu_id/menu_items" do
    it "lists ONLY items on that menu (and in that restaurant), sorted by name ASC" do
      ziti     = create(:menu_item, restaurant: restaurant, name: "Ziti")
      arancini = create(:menu_item, restaurant: restaurant, name: "Arancini")
      outside  = create(:menu_item, restaurant: restaurant, name: "Outside") # not linked to menu

      link_item_to_menu(ziti)
      link_item_to_menu(arancini)
      # no link for `outside`

      get items_path

      expect(response).to have_http_status(:ok)
      expect(json.map { |h| h["name"] }).to eq(%w[Arancini Ziti]) # "Outside" excluded
    end

    it "filters by ?active=false within that menu" do
      off = create(:menu_item, restaurant: restaurant, name: "Off", active: false)
      on  = create(:menu_item, restaurant: restaurant, name: "On",  active: true)
      link_item_to_menu(off)
      link_item_to_menu(on)

      get items_path, params: { active: false }

      expect(response).to have_http_status(:ok)
      expect(json.pluck("name")).to eq([ "Off" ])
    end

    it "ignores disallowed sort fields and falls back to default (name ASC, id tiebreaker)" do
      b = create(:menu_item, restaurant: restaurant, name: "B")
      a = create(:menu_item, restaurant: restaurant, name: "A")
      link_item_to_menu(b)
      link_item_to_menu(a)

      get items_path, params: { sort: "price" } # not whitelisted

      expect(response).to have_http_status(:ok)
      expect(json.map { |h| h["name"] }).to eq(%w[A B])
    end

    it "returns per-menu pricing from the join, not the base item price" do
      lunch  = menu
      dinner = create(:menu, restaurant: restaurant, name: "Dinner")

      item = create(:menu_item, restaurant: restaurant, name: "Burger", price: 99, currency: "USD")
      link_item_to_menu(item, m: lunch,  price: 9.00,  currency: "USD")
      link_item_to_menu(item, m: dinner, price: 15.00, currency: "USD")

      get items_path(m: lunch)
      expect(response).to have_http_status(:ok)
      expect(json.find { |h| h["name"] == "Burger" }["display_price"]).to eq("USD 9.00")

      get items_path(m: dinner)
      expect(response).to have_http_status(:ok)
      expect(json.find { |h| h["name"] == "Burger" }["display_price"]).to eq("USD 15.00")
    end

    it "falls back to the item's base price if the join has no price_on_menu" do
      item = create(:menu_item, restaurant: restaurant, name: "Soup", price: 12.0, currency: "USD")
      link_item_to_menu(item, price: nil, currency: nil) # unpriced link

      get items_path
      expect(response).to have_http_status(:ok)
      expect(json.find { |h| h["name"] == "Soup" }["display_price"]).to eq("USD 12.00")
    end

    it "returns an empty array when the menu has no linked items" do
      get items_path
      expect(response).to have_http_status(:ok)
      expect(json).to eq([])
    end

    it "does not leak items from another restaurant" do
      other_restaurant = create(:restaurant)
      other_menu       = create(:menu, restaurant: other_restaurant, name: "Other Menu")
      foreign_item     = create(:menu_item, restaurant: other_restaurant, name: "Foreign")

      # Link exists, but in a different tenant
      link_item_to_menu(foreign_item, m: other_menu, price: 7.0, currency: "USD")

      get items_path # current restaurant/menu
      expect(response).to have_http_status(:ok)
      expect(json).to be_empty
    end

    context "when parents are invalid" do
      it "returns 422 if the restaurant is invalid" do
        bad_rid = "00000000-0000-0000-0000-000000000000"
        get "/api/v1/restaurants/#{bad_rid}/menus/#{menu.id}/menu_items"

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json["error"]).to be_present
      end

      it "returns 422 if the menu does not belong to the restaurant" do
        other_restaurant = create(:restaurant)
        get items_path(r: other_restaurant, m: menu) # menu belongs to `restaurant`, not `other_restaurant`

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json["error"]).to eq("please provide a valid menu_id")
      end

      it "returns 422 if the menu_id is missing or invalid" do
        get "/api/v1/restaurants/#{restaurant.id}/menus/00000000-0000-0000-0000-000000000000/menu_items"

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json["error"]).to eq("please provide a valid menu_id")
      end
    end
  end

  # ---------------------------------------------------------------------------
  # Show
  # ---------------------------------------------------------------------------
  describe "GET /api/v1/restaurants/:restaurant_id/menus/:menu_id/menu_items/:id" do
    it "returns a single item with its per-menu price when it is on that menu" do
      item = create(:menu_item, restaurant: restaurant, name: "Pizza", price: 18, currency: "USD")
      link_item_to_menu(item, price: 14.50, currency: "USD")

      get item_path(item)

      aggregate_failures do
        expect(response).to have_http_status(:ok)
        expect(json["id"]).to eq(item.id)
        expect(json["name"]).to eq("Pizza")
        expect(json["display_price"]).to eq("USD 14.50")
      end
    end

    it "falls back to base price on show when the join has no price_on_menu" do
      item = create(:menu_item, restaurant: restaurant, name: "Cola", price: 3.25, currency: "USD")
      link_item_to_menu(item, price: nil, currency: nil)

      get item_path(item)

      expect(response).to have_http_status(:ok)
      expect(json["display_price"]).to eq("USD 3.25")
    end

    it "returns 422 if the item exists but is NOT on that menu" do
      item       = create(:menu_item, restaurant: restaurant, name: "Solo")
      other_menu = create(:menu, restaurant: restaurant, name: "Lunch")
      link_item_to_menu(item, m: other_menu) # linked to a different menu

      get item_path(item, m: menu)

      expect(response).to have_http_status(:unprocessable_entity)
      expect(json["error"]).to be_present
    end

    it "returns 422 for a non-existent item id" do
      ghost_id = "00000000-0000-0000-0000-000000000000"
      get "#{items_path}/#{ghost_id}"

      expect(response).to have_http_status(:unprocessable_entity)
      expect(json["error"]).to be_present
    end
  end
end

# frozen_string_literal: true

require "rails_helper"

RSpec.describe "API V1 — Menu Items (nested under Menus)", type: :request do
  # ---------------------------------------------------------------------------
  # Setup
  # ---------------------------------------------------------------------------
  let(:restaurant) { create(:restaurant) }
  let(:menu)       { create(:menu, restaurant: restaurant, name: "Breakfast") }

  # small helpers keep examples tidy
  def items_path(r: restaurant, m: menu)
    "/api/v1/restaurants/#{r.id}/menus/#{m.id}/menu_items"
  end

  def item_path(item, r: restaurant, m: menu)
    "#{items_path(r:, m:)}/#{item.id}"
  end

  def link_item_to_menu(item, m: menu)
    create(:menu_itemization, menu: m, menu_item: item)
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

    context "when parents are invalid" do
      it "returns 422 if the restaurant is invalid" do
        bad_rid = "00000000-0000-0000-0000-000000000000"
        get "/api/v1/restaurants/#{bad_rid}/menus/#{menu.id}/menu_items"

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json["error"]).to be_present # base controller rescue text: "please provide a valid id"
      end

      it "returns 422 if the menu does not belong to the restaurant" do
        other_restaurant = create(:restaurant)
        get items_path(r: other_restaurant, m: menu)

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
    it "returns a single item when it is on that menu" do
      item = create(:menu_item, restaurant: restaurant, name: "Pizza", price: 18)
      link_item_to_menu(item)

      get item_path(item)

      aggregate_failures do
        expect(response).to have_http_status(:ok)
        expect(json["id"]).to eq(item.id)
        expect(json["name"]).to eq("Pizza")
        expect(json["display_price"]).to match(/USD 18\.00/)
      end
    end

    it "returns 422 if the item exists but is NOT on that menu" do
      item       = create(:menu_item, restaurant: restaurant, name: "Solo")
      other_menu = create(:menu, restaurant: restaurant, name: "Lunch")
      link_item_to_menu(item, m: other_menu) # linked to a different menu

      get item_path(item, m: menu)

      expect(response).to have_http_status(:unprocessable_entity)
      expect(json["error"]).to be_present # rescue text: "please provide a valid id"
    end

    it "returns 422 for a non-existent item id" do
      ghost_id = "00000000-0000-0000-0000-000000000000"
      get "#{items_path}/#{ghost_id}"

      expect(response).to have_http_status(:unprocessable_entity)
      expect(json["error"]).to be_present
    end
  end
end

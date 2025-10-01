# frozen_string_literal: true

require "rails_helper"

RSpec.describe "API V1 — Menu Items (nested under Menus)", type: :request do
  let(:restaurant) { create(:restaurant) }
  let(:menu)       { create(:menu, restaurant: restaurant, name: "Breakfast") }

  def link_item_to_menu(item, menu:, price: nil, currency: nil)
    create(:menu_itemization,
           menu: menu,
           menu_item: item,
           price_on_menu: price,
           currency_on_menu: currency)
  end

  describe "GET /api/v1/restaurants/:restaurant_id/menus/:menu_id/menu_items" do
    let(:restaurant_id) { restaurant.id }
    let(:menu_id)       { menu.id }
    let(:params)        { {} }

    def perform_index
      get "/api/v1/restaurants/#{restaurant_id}/menus/#{menu_id}/menu_items", params: params
    end

    context "when the menu already has items" do
      let!(:arancini) { create(:menu_item, restaurant: restaurant, name: "Arancini") }
      let!(:ziti)     { create(:menu_item, restaurant: restaurant, name: "Ziti") }

      before do
        link_item_to_menu(arancini, menu: menu, price: 8.75, currency: "USD")
        link_item_to_menu(ziti,     menu: menu, price: 12.25, currency: "USD")
        perform_index
      end

      it "only lists items linked to the menu" do
        rogue = create(:menu_item, restaurant: restaurant, name: "Not Linked")
        expect(json.pluck("name")).to match_array(%w[Arancini Ziti])
        expect(json.pluck("name")).not_to include(rogue.name)
      end

      it "returns the items alphabetically" do
        expect(json.pluck("name")).to eq(%w[Arancini Ziti])
      end

      it "uses the per-menu pricing" do
        expect(json.find { |entry| entry["name"] == "Arancini" }["display_price"]).to eq("USD 8.75")
      end
    end

    context "when a dish has no per-menu price" do
      let!(:soup) { create(:menu_item, restaurant: restaurant, name: "Soup", price: 11.0, currency: "USD") }

      before do
        link_item_to_menu(soup, menu: menu) # rely on base price
        perform_index
      end

      it "falls back to the item's own pricing" do
        expect(json.find { |entry| entry["name"] == "Soup" }["display_price"]).to eq("USD 11.00")
      end
    end

    context "when customers want to filter by activity" do
      let(:params) { { active: false } }

      before do
        inactive = create(:menu_item, restaurant: restaurant, name: "Sleeping", active: false)
        active   = create(:menu_item, restaurant: restaurant, name: "Awake",    active: true)
        link_item_to_menu(inactive, menu: menu)
        link_item_to_menu(active,   menu: menu)
        perform_index
      end

      it "respects the active filter" do
        expect(json.pluck("name")).to eq([ "Sleeping" ])
      end
    end

    context "when a caller supplies an unsupported sort" do
      let(:params) { { sort: "price" } }

      before do
        create(:menu_item, restaurant: restaurant, name: "A").tap { |item| link_item_to_menu(item, menu: menu) }
        create(:menu_item, restaurant: restaurant, name: "B").tap { |item| link_item_to_menu(item, menu: menu) }
        perform_index
      end

      it "falls back to the default order" do
        expect(json.pluck("name")).to eq(%w[A B])
      end
    end

    context "when the restaurant does not exist" do
      let(:restaurant_id) { SecureRandom.uuid }

      it "returns a not-found error" do
        perform_index
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json["error"]).to eq("please provide a valid restaurant_id")
      end
    end

    context "when the menu does not belong to the restaurant" do
      let(:restaurant_id) { create(:restaurant).id }

      it "returns a menu validation error" do
        perform_index
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json["error"]).to eq("please provide a valid menu_id")
      end
    end

    context "when the menu simply has no items yet" do
      it "returns an empty list" do
        perform_index
        expect(response).to have_http_status(:ok)
        expect(json).to eq([])
      end
    end
  end

  describe "GET /api/v1/restaurants/:restaurant_id/menus/:menu_id/menu_items/:id" do
    let(:restaurant_id) { restaurant.id }
    let(:menu_id)       { menu.id }
    let(:item_id)       { menu_item.id }
    let(:menu_item)     { create(:menu_item, restaurant: restaurant, name: "Pizza", price: 18, currency: "USD") }

    def perform_show
      get "/api/v1/restaurants/#{restaurant_id}/menus/#{menu_id}/menu_items/#{item_id}"
    end

    context "when the menu features the item" do
      before { link_item_to_menu(menu_item, menu: menu, price: 14.50, currency: "USD") }

      it "returns the menu item" do
        perform_show
        expect(response).to have_http_status(:ok)
        expect(json).to include(
          "id" => menu_item.id,
          "name" => "Pizza",
          "display_price" => "USD 14.50"
        )
      end
    end

    context "when the item has no per-menu price" do
      before { link_item_to_menu(menu_item, menu: menu) }

      it "falls back to the base item's display price" do
        perform_show
        expect(json["display_price"]).to eq("USD 18.00")
      end
    end

    context "when the item is not linked to this menu" do
      let(:other_menu) { create(:menu, restaurant: restaurant, name: "Lunch") }

      before { link_item_to_menu(menu_item, menu: other_menu) }

      it "returns an error" do
        perform_show
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json["error"]).to eq("please provide a valid id")
      end
    end

    context "when the item id is unknown" do
      let(:item_id) { SecureRandom.uuid }

      it "returns a validation error" do
        perform_show
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json["error"]).to eq("please provide a valid id")
      end
    end

    context "when the menu id is invalid" do
      let(:menu_id) { SecureRandom.uuid }

      it "returns a menu validation error" do
        perform_show
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json["error"]).to eq("please provide a valid menu_id")
      end
    end
  end
end

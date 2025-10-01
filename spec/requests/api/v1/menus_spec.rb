# frozen_string_literal: true

require "rails_helper"

RSpec.describe "API V1 — Menus (nested under Restaurants)", type: :request do
  let(:restaurant)       { create(:restaurant) }
  let(:other_restaurant) { create(:restaurant) }

  describe "GET /api/v1/restaurants/:restaurant_id/menus" do
    let(:restaurant_id) { restaurant.id }
    let(:params)        { {} }

    def perform_index
      get "/api/v1/restaurants/#{restaurant_id}/menus", params: params
    end

    context "when the restaurant has menus" do
      let!(:alpha_menu) { create(:menu, restaurant: restaurant, name: "Alpha") }
      let!(:zed_menu)   { create(:menu, restaurant: restaurant, name: "Zed") }
      let!(:external)   { create(:menu, restaurant: other_restaurant, name: "Should Not Appear") }

      before { perform_index }

      it "lists only the menus that belong to the restaurant" do
        expect(response).to have_http_status(:ok)
        expect(json.pluck("id")).to contain_exactly(alpha_menu.id, zed_menu.id)
      end

      it "returns the menus alphabetically" do
        expect(json.pluck("name")).to eq(%w[Alpha Zed])
      end

      it "includes the computed status flag" do
        zed_menu.update!(active: false)
        perform_index
        statuses = json.index_by { |entry| entry["name"] }.transform_values { |entry| entry["status"] }
        expect(statuses).to include("Alpha" => "active", "Zed" => "inactive")
      end
    end

    context "when callers filter by activity" do
      let(:params) { { active: false } }

      before do
        create(:menu, restaurant: restaurant, name: "Morning", active: true)
        create(:menu, restaurant: restaurant, name: "After Hours", active: false)
        perform_index
      end

      it "filters by active flag" do
        expect(json.pluck("name")).to eq([ "After Hours" ])
      end
    end

    context "when callers request a descending sort" do
      let(:params) { { sort: "-name" } }

      before do
        create(:menu, restaurant: restaurant, name: "Brunch")
        create(:menu, restaurant: restaurant, name: "Lunch")
        perform_index
      end

      it "accepts the descending sort parameter" do
        expect(json.pluck("name")).to eq(%w[Lunch Brunch])
      end
    end

    context "when the sort parameter is not permitted" do
      let(:params) { { sort: "starts_at" } }

      before do
        create(:menu, restaurant: restaurant, name: "A")
        create(:menu, restaurant: restaurant, name: "B")
        perform_index
      end

      it "falls back to the default ordering" do
        expect(json.pluck("name")).to eq(%w[A B])
      end
    end

    context "when the restaurant id cannot be found" do
      let(:restaurant_id) { SecureRandom.uuid }

      it "returns a not-found error" do
        perform_index
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json["error"]).to eq("please provide a valid restaurant_id")
      end
    end
  end

  describe "GET /api/v1/restaurants/:restaurant_id/menus/:id" do
    let(:restaurant_id) { restaurant.id }
    let(:menu_id)       { menu.id }
    let(:menu)          { create(:menu, restaurant: restaurant, name: "Breakfast") }

    def perform_show
      get "/api/v1/restaurants/#{restaurant_id}/menus/#{menu_id}"
    end

    context "when the menu belongs to the restaurant" do
      it "returns the requested menu" do
        perform_show
        expect(response).to have_http_status(:ok)
        expect(json).to include("id" => menu.id, "name" => "Breakfast", "status" => "active")
      end
    end

    context "when the menu id does not exist" do
      let(:menu_id) { SecureRandom.uuid }

      it "returns an error payload" do
        perform_show
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json["error"]).to eq("please provide a valid id")
      end
    end

    context "when the menu belongs to another restaurant" do
      let(:menu)          { create(:menu, restaurant: other_restaurant) }
      let(:restaurant_id) { restaurant.id }

      it "rejects menus from another restaurant" do
        perform_show
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json["error"]).to eq("please provide a valid id")
      end
    end
  end
end

# frozen_string_literal: true

require "rails_helper"

RSpec.describe "API V1 — Menus (nested under Restaurants)", type: :request do
  let(:restaurant)       { create(:restaurant) }
  let(:other_restaurant) { create(:restaurant) }

  def menus_path(r = restaurant) = "/api/v1/restaurants/#{r.id}/menus"
  def menu_path(menu, r = restaurant) = "#{menus_path(r)}/#{menu.id}"

  describe "GET /api/v1/restaurants/:restaurant_id/menus" do
    it "lists only this restaurant's menus, ordered by name ASC" do
      create(:menu, restaurant: restaurant, name: "Zed")
      create(:menu, restaurant: restaurant, name: "Alpha")
      create(:menu, restaurant: other_restaurant, name: "ShouldNotLeak")

      get menus_path

      expect(response).to have_http_status(:ok)
      names = json.map { |h| h["name"] }
      expect(names).to eq(%w[Alpha Zed])
      expect(names).not_to include("ShouldNotLeak")

      # (Optional stronger check without relying on serializer fields)
      ids = json.map { |h| h["id"] }
      expect(Menu.where(id: ids).pluck(:restaurant_id).uniq).to eq([ restaurant.id ])
    end

    it "filters with ?active=false (within this restaurant)" do
      create(:menu, restaurant: restaurant, name: "Inactive", active: false)
      create(:menu, restaurant: restaurant, name: "Active",   active: true)

      get menus_path, params: { active: false }

      expect(response).to have_http_status(:ok)
      expect(json.pluck("name")).to eq([ "Inactive" ])
    end

    it "supports ?sort=-name (desc) when allowed" do
      create(:menu, restaurant: restaurant, name: "Beta")
      create(:menu, restaurant: restaurant, name: "Alpha")

      get menus_path, params: { sort: "-name" }

      expect(response).to have_http_status(:ok)
      expect(json.map { |h| h["name"] }).to eq(%w[Beta Alpha])
    end

    it "ignores disallowed sort fields and falls back to the default" do
      create(:menu, restaurant: restaurant, name: "B")
      create(:menu, restaurant: restaurant, name: "A")

      # "starts_at" is not in allowed_sort_fields; expect default order (name ASC)
      get menus_path, params: { sort: "starts_at" }

      expect(response).to have_http_status(:ok)
      expect(json.map { |h| h["name"] }).to eq(%w[A B])
    end

    context "when the restaurant is invalid" do
      it "returns 422 with an error payload" do
        bad_id = "00000000-0000-0000-0000-000000000000"
        get "/api/v1/restaurants/#{bad_id}/menus"

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json["error"]).to be_present
      end
    end
  end

  describe "GET /api/v1/restaurants/:restaurant_id/menus/:id" do
    it "returns a single menu with computed status" do
      m = create(:menu, restaurant: restaurant, name: "Breakfast", active: true)

      get menu_path(m)

      expect(response).to have_http_status(:ok)
      expect(json["id"]).to eq(m.id)
      expect(json["name"]).to eq("Breakfast")
      expect(json["status"]).to eq("active")
    end

    it "returns 422 when the menu id does not exist within this restaurant" do
      bad = "00000000-0000-0000-0000-000000000000"
      get "/api/v1/restaurants/#{restaurant.id}/menus/#{bad}"

      expect(response).to have_http_status(:unprocessable_entity)
      expect(json["error"]).to be_present
    end

    it "returns 422 when the menu belongs to a different restaurant" do
      foreign_menu = create(:menu, restaurant: other_restaurant, name: "Foreign")
      get menu_path(foreign_menu, restaurant)

      expect(response).to have_http_status(:unprocessable_entity)
      expect(json["error"]).to be_present
    end
  end
end

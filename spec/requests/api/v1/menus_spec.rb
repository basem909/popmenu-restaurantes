# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Api::V1::Menus", type: :request do
  describe "GET /api/v1/menus" do
    it "returns menus ordered by name ASC, id as tiebreaker" do
      create(:menu, name: "Zed")
      create(:menu, name: "Alpha")

      get "/api/v1/menus"

      expect(response).to have_http_status(:ok)
      expect(json.map { |h| h["name"] }).to eq(%w[Alpha Zed])
    end

    it "filters by ?active=false" do
      create(:menu, :inactive, name: "Inactive")
      create(:menu, name: "Active")

      get "/api/v1/menus", params: { active: false }

      expect(response).to have_http_status(:ok)
      expect(json.pluck("name")).to eq([ "Inactive" ])
    end

    it "supports ?sort=-name (desc)" do
      create(:menu, name: "Beta")
      create(:menu, name: "Alpha")

      get "/api/v1/menus", params: { sort: "-name" }

      expect(response).to have_http_status(:ok)
      expect(json.map { |h| h["name"] }).to eq(%w[Beta Alpha])
    end

    it "ignores disallowed sort fields (nice-to-have)" do
      create(:menu, name: "B")
      create(:menu, name: "A")

      get "/api/v1/menus", params: { sort: "hack" }

      expect(response).to have_http_status(:ok)

      expect(json.map { |h| h["name"] }).to eq(%w[A B])
    end
  end

  describe "GET /api/v1/menus/:id" do
    it "returns a single menu with computed status" do
      menu = create(:menu, name: "Breakfast")

      get "/api/v1/menus/#{menu.id}"

      expect(response).to have_http_status(:ok)
      expect(json["id"]).to eq(menu.id)
      expect(json["name"]).to eq("Breakfast")
      expect(json["status"]).to eq("active")
    end

    it "404s for missing" do
      get "/api/v1/menus/#{SecureRandom.uuid}"

      expect(response).to have_http_status(:not_found)
      expect(json["error"]).to eq("not_found")
    end
  end
end

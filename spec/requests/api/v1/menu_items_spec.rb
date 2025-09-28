# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Api::V1::MenuItems", type: :request do
  describe "GET /api/v1/menu_items" do
    it "returns items ordered by name ASC" do
      create(:menu_item, name: "Ziti")
      create(:menu_item, name: "Arancini")
      get "/api/v1/menu_items"
      expect(response).to have_http_status(:ok)
      expect(json.map { |h| h["name"] }).to eq(%w[Arancini Ziti])
    end

    it "filters by ?active=false" do
      create(:menu_item, :inactive, name: "Off")
      create(:menu_item, name: "On")
      get "/api/v1/menu_items", params: { active: false }
      expect(response).to have_http_status(:ok)
      expect(json.pluck("name")).to eq([ "Off" ])
    end

    it "ignores disallowed sort fields (nice-to-have)" do
      create(:menu_item, name: "B")
      create(:menu_item, name: "A")
      get "/api/v1/menu_items", params: { sort: "price" } # not whitelisted in L1
      expect(response).to have_http_status(:ok)
      expect(json.map { |h| h["name"] }).to eq(%w[A B]) # default sort (name,id)
    end
  end

  describe "GET /api/v1/menu_items/:id" do
    it "returns a single item with display_price" do
      item = create(:menu_item, name: "Pizza", price: 18)
      get "/api/v1/menu_items/#{item.id}"
      expect(response).to have_http_status(:ok)
      expect(json["id"]).to eq(item.id)
      expect(json["name"]).to eq("Pizza")
      expect(json["display_price"]).to match(/USD 18\.00/)
    end
  end
end

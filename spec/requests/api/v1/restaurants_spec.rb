
require "rails_helper"

RSpec.describe "API V1 — Restaurants", type: :request do
  describe "GET /api/v1/restaurants" do
    let(:endpoint) { "/api/v1/restaurants" }

    context "when restaurants exist" do
      before do
        create(:restaurant, name: "Zed")
        create(:restaurant, name: "Alpha")
        get endpoint
      end

      it "returns the restaurants sorted by name" do
        expect(response).to have_http_status(:ok)
        expect(json.pluck("name")).to eq(%w[Alpha Zed])
      end

      it "exposes the key attributes" do
        expect(json.first.keys).to include("id", "name")
      end
    end

    context "when no restaurants exist" do
      it "returns an empty list gracefully" do
        get endpoint
        expect(response).to have_http_status(:ok)
        expect(json).to eq([])
      end
    end
  end

  describe "GET /api/v1/restaurants/:id" do
    context "when the restaurant is found" do
      let(:restaurant) { create(:restaurant, name: "Casa Pop") }

      it "returns the requested restaurant" do
        get "/api/v1/restaurants/#{restaurant.id}"
        expect(response).to have_http_status(:ok)
        expect(json["name"]).to eq("Casa Pop")
      end
    end

    context "when the restaurant does not exist" do
      it "answers with a helpful error" do
        get "/api/v1/restaurants/#{SecureRandom.uuid}"
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json["error"]).to eq("please provide a valid id")
      end
    end
  end
end

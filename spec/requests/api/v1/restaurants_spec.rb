
require "rails_helper"

RSpec.describe "API V1 — Restaurants", type: :request do
  it "lists restaurants ordered by name" do
    create(:restaurant, name: "Zed")
    create(:restaurant, name: "Alpha")

    get "/api/v1/restaurants"

    expect(response).to have_http_status(:ok)
    expect(json.map { |h| h["name"] }).to eq(%w[Alpha Zed])
  end

  it "shows a restaurant" do
    r = create(:restaurant, name: "R1")
    get "/api/v1/restaurants/#{r.id}"
    expect(response).to have_http_status(:ok)
    expect(json["name"]).to eq("R1")
  end
end

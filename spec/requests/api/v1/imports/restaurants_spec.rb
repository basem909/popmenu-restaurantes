# spec/requests/api/v1/imports/restaurants_spec.rb
require "rails_helper"

RSpec.describe "API V1 — Imports::Restaurants (JWT + permission + worker)", type: :request do
  let(:payload) do
    {
      restaurants: [
        { name: "R1", menus: [ { name: "M1", menu_items: [ { name: "X", price: 1.0 } ] } ] }
      ]
    }
  end

  it "rejects unauthenticated" do
    post "/api/v1/imports/restaurants", params: payload.to_json, headers: { "CONTENT_TYPE" => "application/json" }
    expect(response).to have_http_status(:unauthorized)
  end

  it "forbids without page_auth import" do
    user = create(:user)
    headers = auth_headers_for(user)

    post "/api/v1/imports/restaurants", params: payload.to_json, headers: headers.merge("CONTENT_TYPE" => "application/json")
    expect(response).to have_http_status(:forbidden)
  end

  it "enqueues Sidekiq worker and returns 202 when authorized" do
    user = create(:user, :can_import)
    headers = auth_headers_for(user)

    expect {
      post "/api/v1/imports/restaurants", params: payload.to_json, headers: headers.merge("CONTENT_TYPE" => "application/json")
    }.to change(Imports::RestaurantTreeWorker.jobs, :size).by(1)

    expect(response).to have_http_status(:accepted)
    expect(json["enqueued"]).to eq(true)
    expect(json["job_id"]).to be_present
  end

  it "returns 422 for invalid JSON" do
    user = create(:user, :can_import)
    headers = auth_headers_for(user)

    post "/api/v1/imports/restaurants", 
         params: "not-json", 
         headers: headers.merge("CONTENT_TYPE" => "application/json")
    
    expect(response).to have_http_status(:unprocessable_entity)
    expect(json["error"]).to eq("invalid_json")
  end
end

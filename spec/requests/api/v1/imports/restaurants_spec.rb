require "rails_helper"

RSpec.describe "API V1 — Imports::Restaurants", type: :request do
  subject(:perform_request) do
    post "/api/v1/imports/restaurants",
         params: body,
         headers: default_headers.merge(extra_headers)
  end

  let(:body)           { payload.to_json }
  let(:payload) do
    {
      restaurants: [
        {
          name: "R1",
          menus: [
            { name: "M1", menu_items: [ { name: "X", price: 1.0 } ] }
          ]
        }
      ]
    }
  end
  let(:default_headers) { { "CONTENT_TYPE" => "application/json" } }
  let(:extra_headers)   { {} }

  context "when no credentials are provided" do
    it "returns 401 unauthorized" do
      perform_request
      expect(response).to have_http_status(:unauthorized)
    end
  end

  context "when the user is signed in but not allowed to import" do
    let(:user)          { create(:user) }
    let(:extra_headers) { auth_headers_for(user) }

    it "returns 403 forbidden" do
      perform_request
      expect(response).to have_http_status(:forbidden)
      expect(json["error"]).to eq("forbidden")
    end
  end

  context "when the user can import" do
    let(:user)          { create(:user, :can_import) }
    let(:extra_headers) { auth_headers_for(user) }

    it "queues the background worker and returns 202" do
      expect { perform_request }.to change(Imports::RestaurantTreeWorker.jobs, :size).by(1)
      expect(response).to have_http_status(:accepted)
      expect(json).to include("enqueued" => true, "job_id" => a_string_matching(/[a-f0-9]{24}/))
    end

    it "includes the payload in the queued job" do
      perform_request
      job_payload = Imports::RestaurantTreeWorker.jobs.last["args"].last
      expect(job_payload).to eq(JSON.parse(body))
    end
  end

  context "when the payload cannot be parsed as JSON" do
    let(:user)          { create(:user, :can_import) }
    let(:extra_headers) { auth_headers_for(user) }
    let(:body)          { "not-json" }

    it "returns a validation error" do
      perform_request
      expect(response).to have_http_status(:unprocessable_entity)
      expect(json).to include("error" => "invalid_json")
    end
  end
end

# frozen_string_literal: true

require "rails_helper"

RSpec.describe "API V1 — User authentication", type: :request do
  describe "POST /api/v1/users" do
    let(:endpoint) { "/api/v1/users" }
    let(:headers)  { { "CONTENT_TYPE" => "application/json" } }

    context "with valid attributes" do
      let(:payload) do
        {
          user: {
            email: "fresh@example.com",
            password: "Password1!",
            password_confirmation: "Password1!"
          }
        }
      end

      it "creates the user and returns their info" do
        expect {
          post endpoint, params: payload.to_json, headers: headers
        }.to change(User, :count).by(1)

        expect(response).to have_http_status(:ok)
        expect(json).to include("email" => "fresh@example.com")
      end
    end

    context "with invalid attributes" do
      let!(:existing_user) { create(:user, email: "taken@example.com") }
      let(:payload) do
        {
          user: {
            email: existing_user.email,
            password: "Password1!",
            password_confirmation: "Password1!"
          }
        }
      end

      it "returns validation errors" do
        post endpoint, params: payload.to_json, headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json["errors"]).to include("Email has already been taken")
      end
    end
  end

  describe "POST /api/v1/users/sign_in" do
    let(:endpoint) { "/api/v1/users/sign_in" }
    let(:headers)  { { "CONTENT_TYPE" => "application/json" } }
    let!(:user)    { create(:user, password: "Password1!", email: "reader@example.com") }

    it "returns a JWT token on success" do
      payload = { user: { email: user.email, password: "Password1!" } }

      post endpoint, params: payload.to_json, headers: headers

      expect(response).to have_http_status(:ok)
      expect(json).to include("token", "email" => user.email, "user_id" => user.id)
      expect(response.headers["Authorization"]).to be_present
    end

    it "returns 401 for invalid credentials" do
      payload = { user: { email: user.email, password: "WrongPassword!" } }

      post endpoint, params: payload.to_json, headers: headers

      expect(response).to have_http_status(:unauthorized)
      expect(json["error"]).to be_present
    end
  end

  describe "DELETE /api/v1/users/sign_out" do
    let(:endpoint) { "/api/v1/users/sign_out" }

    it "signs the user out when a token is provided" do
      user = create(:user, password: "Password1!")
      token_headers = auth_headers_for(user)

      delete endpoint, headers: token_headers

      expect(response).to have_http_status(:no_content)
    end

    it "returns 401 when the token is missing" do
      delete endpoint

      expect(response).to have_http_status(:unauthorized)
      expect(json["error"]).to eq("missing_token")
    end
  end
end

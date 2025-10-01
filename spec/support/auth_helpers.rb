# spec/support/auth_helpers.rb
module AuthHelpers
  def auth_headers_for(user, password: "Password1!")
    post "/api/v1/users/sign_in",
         params: { user: { email: user.email, password: password } }.to_json,
         headers: { "CONTENT_TYPE" => "application/json" }
    expect(response).to have_http_status(:ok)

    token = json.fetch("token", nil)
    auth_header = response.headers["Authorization"] || (token.present? ? "Bearer #{token}" : nil)
    raise "Missing Authorization header and token" unless auth_header.present?

    { "Authorization" => auth_header }
  end
end

RSpec.configure do |c|
  c.include AuthHelpers, type: :request
end

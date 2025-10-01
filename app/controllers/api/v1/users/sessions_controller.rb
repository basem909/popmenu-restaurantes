module Api
  module V1
    module Users
      class SessionsController < Devise::SessionsController
        respond_to :json

        private

        def respond_with(resource, _opts = {})
          token = request.env['warden-jwt_auth.token'] || authorization_token_from_headers
          render json: {
            user_id: resource.id,
            email: resource.email,
            token: token
          }, status: :ok
        end

        def respond_to_on_destroy
          head :no_content
        end

        def authorization_token_from_headers
          auth_header = response.headers['Authorization'] || request.headers['Authorization']
          return unless auth_header&.start_with?('Bearer ')
          auth_header.split(' ', 2).last
        end
      end
    end
  end
end

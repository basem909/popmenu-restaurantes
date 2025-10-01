module Api
  module V1
    module Users
      # Custom Devise sessions controller that exposes JWT tokens for API clients.
      class SessionsController < Devise::SessionsController
        respond_to :json

        private

        # Render sign-in response including the issued JWT.
        # @param resource [User]
        # @return [void]
        def respond_with(resource, _opts = {})
          token = request.env['warden-jwt_auth.token'] || authorization_token_from_headers

          render json: {
            user_id: resource.id,
            email: resource.email,
            token: token
          }, status: :ok
        end

        # Override Devise's default to deliver consistent API semantics.
        # @return [void]
        def respond_to_on_destroy
          if request.headers['Authorization'].present?
            head :no_content
          else
            render json: { error: 'missing_token' }, status: :unauthorized
          end
        end

        # Returns the JWT token from either the response or request headers.
        # @return [String, nil]
        def authorization_token_from_headers
          auth_header = response.headers['Authorization'] || request.headers['Authorization']
          return unless auth_header&.start_with?('Bearer ')

          auth_header.split(' ', 2).last
        end
      end
    end
  end
end

module Api
    module V1
      module Users
        class RegistrationsController < Devise::RegistrationsController
          respond_to :json

          private

          def respond_with(resource, _opts = {})
            if resource.persisted?
              render json: { user_id: resource.id, email: resource.email }, status: :ok
            else
              render json: { errors: resource.errors.full_messages }, status: :unprocessable_entity
            end
          end
        end
      end
    end
end

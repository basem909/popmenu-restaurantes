module Api
  module V1
    module Users
      class RegistrationsController < Devise::RegistrationsController
        respond_to :json

        rescue_from ActiveRecord::RecordNotUnique, with: :handle_duplicate_email

        private

        def respond_with(resource, _opts = {})
          if resource.persisted?
            render json: { user_id: resource.id, email: resource.email }, status: :ok
          else
            render json: { errors: resource.errors.full_messages }, status: :unprocessable_entity
          end
        end

        protected

        def sign_up(_resource_name, _resource)
          # sessionless API: skip Devise writing to session store
        end

        def handle_duplicate_email(_exception)
          render json: { errors: ['Email has already been taken'] }, status: :unprocessable_entity
        end
      end
    end
  end
end

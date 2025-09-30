# app/controllers/api/v1/imports/restaurants_controller.rb

module Api
  module V1
    module Imports
      # Controller for handling restaurant import operations
      # Requires user authentication and import page authorization
      class RestaurantsController < Api::BaseController
        before_action :authenticate_user!
        before_action -> { require_page_auth!("import") }

        # Create a new restaurant import job
        # Accepts JSON payload and enqueues background job for processing
        def create
          payload = parse_payload!
          job_id = ::Imports::RestaurantTreeWorker.perform_async(current_user.id, payload)
          
          render json: { 
            enqueued: true, 
            job_id: job_id,
            message: "Restaurant import job has been queued for processing"
          }, status: :accepted
        rescue JSON::ParserError
          render json: { 
            error: "invalid_json",
            message: "The provided data is not valid JSON. Please check your request format and try again."
          }, status: :unprocessable_entity
        end

        private

        # Parse the request payload from either raw POST body or params
        # Returns parsed JSON hash for job processing
        def parse_payload!
          raw_payload = request.raw_post.presence || params.to_unsafe_h.to_json
          JSON.parse(raw_payload) 
        end
      end
    end
  end
end
  
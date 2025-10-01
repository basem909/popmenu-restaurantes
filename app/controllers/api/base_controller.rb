module Api
    class BaseController < ActionController::API
      include ActionController::MimeResponds

      before_action :set_default_format
      rescue_from JSON::ParserError, with: :handle_json_parse_error


      def permitted_params
        base_attributes = default_permitted_attributes
        additional_attributes = additional_permitted_attributes if respond_to?(:additional_permitted_attributes, true)

        all_attributes = additional_attributes.present? ? base_attributes + Array(additional_attributes) : base_attributes
        params.require(resource_param_key).permit(*all_attributes)
      end

      private

      def resource_param_key
        model_class.model_name.singular
      end

      def default_permitted_attributes
        PermittedAttributes.for(resource_param_key)
      end

      def set_default_format
        request.format = :json
      end

      def require_page_auth!(key)
        unless current_user&.can_page?(key)
          render json: { error: "forbidden" }, status: :forbidden
        end
      end

      def handle_json_parse_error(exception)
        render json: {
          error: "invalid_json",
          message: "The provided data is not valid JSON. Please check your request format and try again."
        }, status: :unprocessable_entity
      end
    end
end

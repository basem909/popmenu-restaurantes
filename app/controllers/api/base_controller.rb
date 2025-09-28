module Api
    class BaseController < ActionController::API
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
    end
end

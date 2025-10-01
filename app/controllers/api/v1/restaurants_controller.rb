module Api
  module V1
    class RestaurantsController < ResourceController
      private

      def model_class
        Restaurant
      end

      def include_relations
        []
      end

      def default_sort_order
        { name: :asc, id: :asc }
      end

      def allowed_sort_fields
        %i[name]
      end

      def additional_permitted_attributes
        []
      end
    end
  end
end

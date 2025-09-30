module Api
  module V1
    class MenuItemsController < ResourceController
      before_action :ensure_current_restaurant!, only: %i[index show]
      before_action :ensure_current_menu!, only: %i[index show]

      private

      def ensure_current_menu!
        @current_menu = @current_restaurant.menus.find_by(id: params[:menu_id])
        render json: { error: "please provide a valid menu_id" }, status: :unprocessable_entity unless @current_menu.present?
      end

      def resource_scope
        @current_menu
          .menu_items
          .where(restaurant_id: @current_restaurant.id)
      end

      def model_class
        MenuItem
      end

      def include_relations
        [ :menu_itemizations ]
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

      def serialize_collection(records)
        collection_serializer_klass
          .new(records, context: { menu: @current_menu, restaurant: @current_restaurant })
          .as_json
      end

      def serialize_resource(record)
        resource_serializer_klass
          .new(record, context: { menu: @current_menu, restaurant: @current_restaurant })
          .as_json
      end
    end
  end
end

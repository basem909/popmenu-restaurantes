module Api
    module V1
      class ResourceController < Api::BaseController
        def index
          render json: serialize_collection(collection_scope)
        end

        def show
          render json: serialize_resource(find_resource)
        end

        rescue_from ActiveRecord::RecordNotFound do
          render json: { error: "not_found" }, status: :not_found
        end

        private


        def resource_scope
          model_class.all
        end

        def include_relations
          []
        end

        def apply_includes(scope)
          relations = include_relations
          return scope unless relations.present?
          scope.includes(*relations)
        end

        def apply_filters(scope)
          return scope unless params.key?(:active)
          active = ActiveModel::Type::Boolean.new.cast(params[:active])
          scope.where(active: active)
        end

        def default_sort_order
          nil
        end

        def requested_sort_order
          return unless params[:sort].present?

          allowed = allowed_sort_fields
          parts   = params[:sort].to_s.split(",")

          order = {}
          parts.each do |part|
            direction = part.start_with?("-") ? :desc : :asc
            field     = part.delete_prefix("-").to_sym
            next unless allowed.include?(field)
            order[field] = direction
          end

          order.presence
        end

        def allowed_sort_fields
          []
        end

        def apply_sort(scope)
          order = requested_sort_order || default_sort_order
          return scope unless order.present?
          scope.order(order)
        end

        def collection_scope
          scope = resource_scope
          scope = apply_includes(scope)
          scope = apply_filters(scope)
          apply_sort(scope)
        end

        def find_resource
          collection_scope.find(params[:id])
        end

        def collection_serializer_klass
          Api::Deps.serializer_for(model_class, :collection)
        end

        def resource_serializer_klass
          Api::Deps.serializer_for(model_class, :resource)
        end

        def serialize_collection(records)
          collection_serializer_klass.new(records).as_json
        end

        def serialize_resource(record)
          resource_serializer_klass.new(record).as_json
        end
      end
    end
end

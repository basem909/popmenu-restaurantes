module Api
    module Deps
      extend self

      SERIALIZERS = {
        "Menu" => {
          collection: Api::V1::MenuCollectionSerializer,
          resource:   Api::V1::MenuSerializer
        },
        "MenuItem" => {
          collection: Api::V1::MenuItemCollectionSerializer,
          resource:   Api::V1::MenuItemSerializer
        }
      }.freeze

      def serializer_for(model_class, kind)
        mapping = SERIALIZERS.fetch(model_class.name) do
          raise KeyError, "No serializers registered for #{model_class.name}"
        end
        mapping.fetch(kind) do
          raise KeyError, "Unknown serializer kind=#{kind.inspect} for #{model_class.name}"
        end
      end
    end
end

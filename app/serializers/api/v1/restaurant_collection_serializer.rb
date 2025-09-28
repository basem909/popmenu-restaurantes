module Api
    module V1
      class RestaurantCollectionSerializer < Api::BaseSerializer
        attributes :id, :name
      end
    end
end

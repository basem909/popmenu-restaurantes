module Api
    module V1
      class RestaurantSerializer < Api::BaseSerializer
        attributes :id, :name
      end
    end
end

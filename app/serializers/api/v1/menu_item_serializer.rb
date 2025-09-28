module Api
    module V1
      class MenuItemSerializer < Api::BaseSerializer
        attributes :id, :name, :description, :price, :currency, :active
        attribute(:display_price) { |i| "#{i.currency} #{format('%.2f', i.price)}" }
      end
    end
end

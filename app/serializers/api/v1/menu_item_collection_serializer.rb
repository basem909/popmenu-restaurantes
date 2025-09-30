# app/serializers/api/v1/menu_item_collection_serializer.rb
module Api
  module V1
    class MenuItemCollectionSerializer < Api::BaseSerializer
      attributes :id, :name, :active, :restaurant_id

      attribute :price do |item|
        menu_id = context[:menu]&.id
        link    = item.menu_itemizations.find { |mi| mi.menu_id == menu_id }
        (link&.price_on_menu || item.price).to_f
      end

      attribute :currency do |item|
        menu_id = context[:menu]&.id
        link    = item.menu_itemizations.find { |mi| mi.menu_id == menu_id }
        link&.currency_on_menu || item.currency
      end

      attribute :display_price do |item|
        menu_id = context[:menu]&.id
        link    = item.menu_itemizations.find { |mi| mi.menu_id == menu_id }
        price    = link&.price_on_menu || item.price || 0
        currency = link&.currency_on_menu || item.currency
        "#{currency} #{format('%.2f', price)}"
      end
    end
  end
end

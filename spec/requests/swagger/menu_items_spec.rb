require 'swagger_helper'

RSpec.describe 'Menu Items API', swagger_doc: 'v1/swagger.yaml', type: :request do
  let(:restaurant) { create(:restaurant) }
  let(:menu)       { create(:menu, restaurant: restaurant) }

  path '/api/v1/restaurants/{restaurant_id}/menus/{menu_id}/menu_items' do
    parameter name: :restaurant_id, in: :path, type: :string, format: :uuid, description: 'Restaurant ID', required: true
    parameter name: :menu_id, in: :path, type: :string, format: :uuid, description: 'Menu ID', required: true

    get 'List menu items for a menu' do
      tags 'Menu Items'
      produces 'application/json'
      parameter name: :active,
                in: :query,
                schema: { type: :boolean },
                description: 'Filter by active status'
      parameter name: :sort,
                in: :query,
                schema: { type: :string, example: 'name,-name' },
                description: 'Comma-separated fields; prefix with - for descending order'

      let(:active) { nil }
      let(:sort)   { nil }

      response '200', 'menu items listed' do
        schema type: :array,
               items: {
                 type: :object,
                 properties: {
                   id:            { type: :string, format: :uuid },
                   name:          { type: :string },
                   active:        { type: :boolean },
                   restaurant_id: { type: :string, format: :uuid },
                   price:         { type: :number, format: :float },
                   currency:      { type: :string },
                   display_price: { type: :string }
                 },
                 required: %w[id name active restaurant_id price currency display_price]
               }

        let(:restaurant_id) { restaurant.id }
        let(:menu_id)       { menu.id }

        before do
          burger = create(:menu_item, restaurant: restaurant, name: 'Burger', price: 8.0, currency: 'USD')
          salad  = create(:menu_item, restaurant: restaurant, name: 'Salad', price: 5.0, currency: 'USD', active: false)
          create(:menu_itemization, menu:, menu_item: burger, price_on_menu: 9.5, currency_on_menu: 'USD')
          create(:menu_itemization, menu:, menu_item: salad)
        end

        run_test!
      end

      response '422', 'menu not found' do
        schema type: :object,
               properties: {
                 error: { type: :string }
               },
               required: %w[error]

        let(:restaurant_id) { restaurant.id }
        let(:menu_id)       { SecureRandom.uuid }

        run_test!
      end
    end
  end

  path '/api/v1/restaurants/{restaurant_id}/menus/{menu_id}/menu_items/{id}' do
    parameter name: :restaurant_id, in: :path, type: :string, format: :uuid, description: 'Restaurant ID', required: true
    parameter name: :menu_id, in: :path, type: :string, format: :uuid, description: 'Menu ID', required: true
    parameter name: :id, in: :path, type: :string, format: :uuid, description: 'Menu item ID', required: true

    get 'Retrieve a menu item' do
      tags 'Menu Items'
      produces 'application/json'

      response '200', 'menu item retrieved' do
        schema type: :object,
               properties: {
                 id:            { type: :string, format: :uuid },
                 name:          { type: :string },
                 description:   { type: :string, nullable: true },
                 active:        { type: :boolean },
                 restaurant_id: { type: :string, format: :uuid },
                 price:         { type: :number, format: :float },
                 currency:      { type: :string },
                 display_price: { type: :string }
               },
               required: %w[id name active restaurant_id price currency display_price]

        let(:restaurant_id) { restaurant.id }
        let(:menu_id)       { menu.id }
        let(:menu_item)     { create(:menu_item, restaurant: restaurant, name: 'Pizza', price: 12.0, currency: 'USD') }
        let(:id)            { menu_item.id }

        before do
          create(:menu_itemization, menu:, menu_item: menu_item, price_on_menu: 10.5, currency_on_menu: 'USD')
        end

        run_test!
      end

      response '422', 'menu item not found' do
        schema type: :object,
               properties: {
                 error: { type: :string }
               },
               required: %w[error]

        let(:restaurant_id) { restaurant.id }
        let(:menu_id)       { menu.id }
        let(:id)            { SecureRandom.uuid }

        run_test!
      end
    end
  end
end

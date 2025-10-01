require 'swagger_helper'

RSpec.describe 'Menus API', swagger_doc: 'v1/swagger.yaml', type: :request do
  let(:restaurant) { create(:restaurant) }

  path '/api/v1/restaurants/{restaurant_id}/menus' do
    parameter name: :restaurant_id, in: :path, type: :string, format: :uuid, description: 'Restaurant ID', required: true

    get 'List menus for a restaurant' do
      tags 'Menus'
      produces 'application/json'
      parameter name: :active,
                in: :query,
                schema: { type: :boolean },
                description: 'Filter by active status'
      parameter name: :sort,
                in: :query,
                schema: { type: :string, example: 'name,-name' },
                description: 'Comma-separated fields; prefix with - for descending order'

      response '200', 'menus listed' do
        schema type: :array,
               items: {
                 type: :object,
                 properties: {
                   id:        { type: :string, format: :uuid },
                   name:      { type: :string },
                   active:    { type: :boolean },
                   starts_at: { type: :string, format: 'date-time', nullable: true },
                   ends_at:   { type: :string, format: 'date-time', nullable: true },
                   status:    { type: :string, enum: %w[active inactive] }
                 },
                 required: %w[id name active status]
               }

        let(:restaurant_id) { restaurant.id }

        before do
          create(:menu, restaurant: restaurant, name: 'Breakfast')
          create(:menu, restaurant: restaurant, name: 'Dinner', active: false)
        end

        run_test!
      end

      response '422', 'restaurant not found' do
        schema type: :object,
               properties: {
                 error: { type: :string }
               },
               required: %w[error]

        let(:restaurant_id) { SecureRandom.uuid }

        run_test!
      end
    end
  end

  path '/api/v1/restaurants/{restaurant_id}/menus/{id}' do
    parameter name: :restaurant_id, in: :path, type: :string, format: :uuid, description: 'Restaurant ID', required: true
    parameter name: :id, in: :path, type: :string, format: :uuid, description: 'Menu ID', required: true

    get 'Retrieve a menu' do
      tags 'Menus'
      produces 'application/json'

      response '200', 'menu retrieved' do
        schema type: :object,
               properties: {
                 id:          { type: :string, format: :uuid },
                 name:        { type: :string },
                 description: { type: :string, nullable: true },
                 active:      { type: :boolean },
                 starts_at:   { type: :string, format: 'date-time', nullable: true },
                 ends_at:     { type: :string, format: 'date-time', nullable: true },
                 status:      { type: :string, enum: %w[active inactive] }
               },
               required: %w[id name active status]

        let(:restaurant_id) { restaurant.id }
        let(:menu) { create(:menu, restaurant: restaurant, name: 'Lunch') }
        let(:id) { menu.id }

        run_test!
      end

      response '422', 'menu not found' do
        schema type: :object,
               properties: {
                 error: { type: :string }
               },
               required: %w[error]

        let(:restaurant_id) { restaurant.id }
        let(:id) { SecureRandom.uuid }

        run_test!
      end
    end
  end
end

require 'swagger_helper'

RSpec.describe 'Restaurants API', swagger_doc: 'v1/swagger.yaml', type: :request do
  path '/api/v1/restaurants' do
    get 'List restaurants' do
      tags 'Restaurants'
      produces 'application/json'
      parameter name: :sort,
                in: :query,
                schema: { type: :string, example: 'name,-name' },
                description: 'Comma-separated fields; prefix with - for descending order'

      response '200', 'restaurants listed' do
        schema type: :array,
               items: {
                 type: :object,
                 properties: {
                   id:   { type: :string, format: :uuid },
                   name: { type: :string }
                 },
                 required: %w[id name]
               }

        before do
          create(:restaurant, name: 'Alpha')
          create(:restaurant, name: 'Zed')
        end

        run_test!
      end
    end
  end

  path '/api/v1/restaurants/{id}' do
    parameter name: :id, in: :path, type: :string, format: :uuid, description: 'Restaurant ID', required: true

    get 'Retrieve a restaurant' do
      tags 'Restaurants'
      produces 'application/json'

      response '200', 'restaurant retrieved' do
        schema type: :object,
               properties: {
                 id:   { type: :string, format: :uuid },
                 name: { type: :string }
               },
               required: %w[id name]

        let(:restaurant) { create(:restaurant) }
        let(:id) { restaurant.id }

        run_test!
      end

      response '422', 'invalid restaurant id' do
        schema type: :object,
               properties: {
                 error: { type: :string }
               },
               required: %w[error]

        let(:id) { SecureRandom.uuid }

        run_test!
      end
    end
  end
end

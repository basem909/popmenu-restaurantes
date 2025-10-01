require 'swagger_helper'

RSpec.describe 'Restaurant Imports API', swagger_doc: 'v1/swagger.yaml', type: :request do
  path '/api/v1/imports/restaurants' do
    post 'Queue a restaurant import job' do
      tags 'Imports'
      consumes 'application/json'
      produces 'application/json'
      security [{ bearerAuth: [] }]

      parameter name: :payload,
                in: :body,
                required: true,
                schema: {
                  type: :object,
                  properties: {
                    restaurants: {
                      type: :array,
                      items: {
                        type: :object,
                        properties: {
                          name: { type: :string },
                          menus: {
                            type: :array,
                            items: {
                              type: :object,
                              properties: {
                                name: { type: :string },
                                menu_items: {
                                  type: :array,
                                  items: {
                                    type: :object,
                                    properties: {
                                      name:  { type: :string },
                                      price: { type: :number, format: :float },
                                      currency: { type: :string }
                                    },
                                    required: %w[name]
                                  }
                                }
                              },
                              required: %w[name]
                            }
                          }
                        },
                        required: %w[name]
                      }
                    }
                  },
                  required: %w[restaurants]
                }

      response '202', 'import enqueued' do
        schema type: :object,
               properties: {
                 enqueued: { type: :boolean },
                 job_id:   { type: :string },
                 message:  { type: :string }
               },
               required: %w[enqueued job_id message]

        let(:user) { create(:user, :can_import) }
        let(:Authorization) { auth_headers_for(user)['Authorization'] }
        let(:payload) do
          {
            restaurants: [
              {
                name: 'Cafe 123',
                menus: [
                  {
                    name: 'Breakfast',
                    menu_items: [ { name: 'Pancakes', price: 8.5, currency: 'USD' } ]
                  }
                ]
              }
            ]
          }
        end

        run_test!
      end

      response '401', 'unauthorized' do
        schema type: :object,
               properties: {
                 error: { type: :string }
               },
               required: %w[error]

        let(:payload) { { restaurants: [] } }

        run_test!
      end

      response '403', 'forbidden' do
        schema type: :object,
               properties: {
                 error: { type: :string }
               },
               required: %w[error]

        let(:user) { create(:user) }
        let(:Authorization) { auth_headers_for(user)['Authorization'] }
        let(:payload) { { restaurants: [] } }

        run_test!
      end

      response '422', 'invalid JSON payload' do
        schema type: :object,
               properties: {
                 error:   { type: :string },
                 message: { type: :string }
               },
               required: %w[error message]

        let(:user) { create(:user, :can_import) }
        let(:payload) { { restaurants: [] } }

        before do
          @auth_headers = auth_headers_for(user)
          allow(JSON).to receive(:parse).and_raise(JSON::ParserError)
        end

        let(:Authorization) { @auth_headers['Authorization'] }

        run_test!
      end
    end
  end
end

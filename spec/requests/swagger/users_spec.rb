require 'swagger_helper'

RSpec.describe 'User Authentication API', swagger_doc: 'v1/swagger.yaml', type: :request do
  path '/api/v1/users' do
    post 'Register a new user' do
      tags 'Users'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :user,
                in: :body,
                required: true,
                schema: {
                  type: :object,
                  properties: {
                    user: {
                      type: :object,
                      properties: {
                        email:                 { type: :string, format: :email },
                        password:              { type: :string, minLength: 8 },
                        password_confirmation: { type: :string, minLength: 8 }
                      },
                      required: %w[email password password_confirmation]
                    }
                  },
                  required: %w[user]
                }

      response '200', 'user registered' do
        schema type: :object,
               properties: {
                 user_id: { type: :integer },
                 email:   { type: :string, format: :email }
               },
               required: %w[user_id email]

        let(:user) do
          {
            user: {
              email: 'new.user@example.com',
              password: 'Password1!',
              password_confirmation: 'Password1!'
            }
          }
        end

        run_test!
      end

      response '422', 'invalid registration' do
        schema type: :object,
               properties: {
                 errors: {
                   type: :array,
                   items: { type: :string }
                 }
               },
               required: %w[errors]

        let!(:existing_user) { create(:user, email: 'taken@example.com') }
        let(:user) do
          {
            user: {
              email: existing_user.email,
              password: 'Password1!',
              password_confirmation: 'Password1!'
            }
          }
        end

        run_test!
      end
    end
  end

  path '/api/v1/users/sign_in' do
    post 'Sign in a user' do
      tags 'Users'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :user,
                in: :body,
                required: true,
                schema: {
                  type: :object,
                  properties: {
                    user: {
                      type: :object,
                      properties: {
                        email:    { type: :string, format: :email },
                        password: { type: :string }
                      },
                      required: %w[email password]
                    }
                  },
                  required: %w[user]
                }

      let(:account) { create(:user, password: 'Password1!') }

      response '200', 'signed in' do
        schema type: :object,
               properties: {
                 user_id: { type: :integer },
                 email:   { type: :string, format: :email },
                 token:   { type: :string }
               },
               required: %w[user_id email token]
        header 'Authorization', schema: { type: :string }

        let(:user) do
          {
            user: {
              email: account.email,
              password: 'Password1!'
            }
          }
        end

        run_test!
      end

      response '401', 'invalid credentials' do
        schema type: :object,
               properties: {
                 error: { type: :string }
               },
               required: %w[error]

        let(:user) do
          {
            user: {
              email: account.email,
              password: 'WrongPassword!'
            }
          }
        end

        run_test!
      end
    end
  end

  path '/api/v1/users/sign_out' do
    delete 'Sign out the current user' do
      tags 'Users'
      produces 'application/json'
      security [ { bearerAuth: [] } ]

      response '204', 'signed out' do
        let(:user) { create(:user, password: 'Password1!') }

        before do
          @auth_headers = auth_headers_for(user)
        end

        let(:Authorization) { @auth_headers['Authorization'] }

        run_test!
      end

      response '401', 'missing token' do
        schema type: :object,
               properties: {
                 error: { type: :string }
               },
               required: %w[error]

        let(:Authorization) { nil }

        run_test! do |response|
          expect(JSON.parse(response.body)).to include('error' => 'missing_token')
        end
      end
    end
  end
end

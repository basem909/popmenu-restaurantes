# config/routes.rb
Rails.application.routes.draw do
  # Devise routes for user authentication
  devise_for :users,
    path: "api/v1/users",
    defaults: { format: :json },
    controllers: {
      sessions:      "api/v1/users/sessions",
      registrations: "api/v1/users/registrations"
    }

  # API routes
  namespace :api do
    namespace :v1, defaults: { format: :json } do
      # Import routes
      namespace :imports do
        resources :restaurants, only: :create
      end

      # Restaurant hierarchy routes
      resources :restaurants, only: %i[index show] do
        resources :menus, only: %i[index show] do
          resources :menu_items, only: %i[index show]
        end
      end
    end
  end
end

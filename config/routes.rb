# config/routes.rb
Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :restaurants, only: %i[index show] do
        resources :menus, only: %i[index show] do
          resources :menu_items, only: %i[index show]
        end
      end
    end
  end
end

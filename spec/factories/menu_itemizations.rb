# spec/factories/menu_itemizations.rb
FactoryBot.define do
  factory :menu_itemization do
    menu
    menu_item { association :menu_item, restaurant: menu.restaurant }

    price_on_menu    { nil }
    currency_on_menu { nil }

    trait :priced do
      price_on_menu    { 9.50 }
      currency_on_menu { "USD" }
    end
  end
end

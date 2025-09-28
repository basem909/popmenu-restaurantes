# spec/factories/menu_itemizations.rb
FactoryBot.define do
    factory :menu_itemization do
      association :menu
      association :menu_item, restaurant: ->(mi) { mi.menu.restaurant }
    end
  end

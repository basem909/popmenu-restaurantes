# frozen_string_literal: true

FactoryBot.define do
    sequence(:menu_item_name) { |n| "Item #{n}" }

    factory :menu_item do
      association :menu
      name        { generate(:menu_item_name) }
      description { "Tasty!" }
      price       { 12.50 }
      currency    { "USD" }
      active      { true }

      trait :inactive do
        active { false }
      end
    end
  end

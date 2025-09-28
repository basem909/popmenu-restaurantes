FactoryBot.define do
  sequence(:menu_name) { |n| "Menu #{n}" }

  factory :menu do
    association :restaurant
    name        { generate(:menu_name) }
    description { "A nice selection" }
    active      { true }

    trait :inactive do
      active { false }
    end
  end
end

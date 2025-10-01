FactoryBot.define do
  sequence(:restaurant_name) { |n| "Restaurant #{n}" }

  factory :restaurant do
    name { generate(:restaurant_name) }
  end
end

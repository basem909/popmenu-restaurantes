FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { "Password1!" }
    page_auth { [] }

    trait :can_import do
      page_auth { ["import"] }
    end

  end
end

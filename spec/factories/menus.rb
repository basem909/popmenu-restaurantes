# frozen_string_literal: true

FactoryBot.define do
    sequence(:menu_name) { |n| "Menu #{n}" }

    factory :menu do
      name        { generate(:menu_name) }
      description { "A nice selection" }
      active      { true }
      starts_at   { nil }
      ends_at     { nil }

      trait :inactive do
        active { false }
      end
    end
  end

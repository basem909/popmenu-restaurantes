FactoryBot.define do
  factory :jwt_denylist, class: "JwtDenylist" do
    sequence(:jti) { SecureRandom.uuid }
    exp { 1.day.from_now }

    trait :expired do
      exp { 1.day.ago }
    end
  end
end

FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    password { 'password' }

    trait :merchant do
      role { 'merchant' }
    end

    trait :admin do
      role { 'admin' }
    end
  end
end

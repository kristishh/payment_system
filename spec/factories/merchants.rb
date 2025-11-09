FactoryBot.define do
  factory :merchant do
    association :user
    name { 'Cool Merchant' }
    status { :active }

    trait :inactive do
      status { :inactive }
    end
  end
end

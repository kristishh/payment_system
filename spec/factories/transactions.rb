FactoryBot.define do
  factory :transaction do
    association :merchant

    amount { 100.00 }
    customer_email { Faker::Internet.email }
    customer_phone { '5551234567' }

    status { :approved }

    reference_transaction_id { nil }

    trait :errored do
      status { :error }
    end

    factory :authorize_transaction, class: 'AuthorizeTransaction' do
      status { :error }

      trait :approved do
        status { :approved }
      end

      trait :reversed do
        status { :reversed }
      end

      trait :refunded do
        status { :refunded }
      end
    end

    factory :charge_transaction, class: 'ChargeTransaction' do
      association :reference_transaction, factory: %i[authorize_transaction approved]

      status { :approved }
    end

    factory :refund_transaction, class: 'RefundTransaction' do
      association :reference_transaction, factory: %i[authorize_transaction approved]

      amount { 50.00 }

      status { :approved }
    end

    factory :reversal_transaction, class: 'ReversalTransaction' do
      association :reference_transaction, factory: %i[authorize_transaction approved]

      amount { nil }

      status { :approved }
    end
  end
end

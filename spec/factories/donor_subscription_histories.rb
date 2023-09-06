FactoryBot.define do
    factory :donor_subscription_history do
        last_paid {Time.now}
    end
  end
  
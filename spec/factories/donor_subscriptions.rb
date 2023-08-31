FactoryBot.define do
    factory :donor_subscription do
        subscription {build(:subscription)}
        last_updated {false}
    end
  end
  
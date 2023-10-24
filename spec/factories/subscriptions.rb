FactoryBot.define do
    factory :subscription do
      plan  {"Monthly"}
      no_of_months {"1 Month"}
      amount {100}
      status {true}
    end
  end
  
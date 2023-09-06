FactoryBot.define do
    factory :payment do
      mode {"online"}
      is_one_time_payment {false}
      amount {20000}
      payment_date {Time.now}
      transaction_id {"1234SDFA"}
      settled {false}
    end
  end
  
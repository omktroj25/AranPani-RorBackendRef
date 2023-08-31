FactoryBot.define do
  factory :family do
    last_updated {false}
    subscription {create(:subscription)}
    count {0}
  end
end

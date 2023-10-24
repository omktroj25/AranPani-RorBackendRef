FactoryBot.define do
    factory :donor do
        donor_reg_no {"DON123"}
        is_area_representative {false}
        role {Donor.roles[:individual_donor]}
        donor_subscription {build(:donor_subscription)}
      status {true}
    end
  end
  
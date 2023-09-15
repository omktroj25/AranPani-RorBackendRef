FactoryBot.define do
    factory :project do
        reg_no {"TEM223"}
        temple_name {"Arul Temple"}
        incharge_name {"Kannan"}
        phonenumber {"923832812"}
        location {"Chennai"}
        status {Project.statuses[:Proposed]}
    end
  end
  
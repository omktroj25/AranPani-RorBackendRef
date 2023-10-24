class DonorsFamilyHistory < ApplicationRecord
  belongs_to :donor
  belongs_to :family_history
end

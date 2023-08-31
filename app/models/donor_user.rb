class DonorUser < ApplicationRecord
    enum gender: [:male,:female]
    validates :phonenumber, uniqueness: true,presence:true,on: :create
    validates :name,presence:true
    has_one :image,as: :imageable
    belongs_to :donor
    reverse_geocoded_by :latitude, :longitude
end

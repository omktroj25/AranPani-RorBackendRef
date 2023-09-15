class DonorUser < ApplicationRecord
    enum gender: [:male,:female]
    validates :phonenumber, uniqueness: true,presence:true
    validates :name,presence:true
    validates :email, presence:false,format: {with:URI::MailTo::EMAIL_REGEXP,message:"Invalid mail Id"},unless: lambda { self.email.blank? }
    has_one :image,as: :imageable
    belongs_to :donor
    reverse_geocoded_by :latitude, :longitude
end

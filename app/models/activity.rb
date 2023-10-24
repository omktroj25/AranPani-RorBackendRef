class Activity < ApplicationRecord
  belongs_to :project
  has_many :images,as: :imageable,autosave:true
end

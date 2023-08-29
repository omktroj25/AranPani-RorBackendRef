class Project < ApplicationRecord
    enum status: [:Proposed,:Planned,:Active,:Completed,:Scrapped]
    has_many :images,as: :imageable
    has_many :project_documents
    has_many :activities
    
    has_many :project_subscribers
    has_many :donors,through: :project_subscribers
end

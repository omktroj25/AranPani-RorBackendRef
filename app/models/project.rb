class Project < ApplicationRecord
    enum status: [:Proposed,:Planned,:Active,:Completed,:Scrapped]
    has_many :images,as: :imageable,autosave:true
    has_many :project_documents,autosave:true
    has_many :activities,autosave:true
    
    has_many :project_subscribers
    has_many :donors,through: :project_subscribers
    reverse_geocoded_by :latitude, :longitude
    scope :search,->(params){where(["incharge_name LIKE ? or phonenumber LIKE ? or reg_no LIKE ?","%#{params[:search]}%","%#{params[:search]}%","%#{params[:search]}%"]).where(status:Project.statuses[params[:status]])}
end

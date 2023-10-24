class ProjectSubscriber < ApplicationRecord
  belongs_to :donor
  belongs_to :project
end

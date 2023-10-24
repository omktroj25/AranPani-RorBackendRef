class ProjectSerializer < ActiveModel::Serializer
  attributes :id,:temple_name,:incharge_name,:location,:status,:created_at,:project_documents,:project_subscribers
  has_many :activities,each_serializer:ActivitySerializer
  has_many :images,serializer:ImageSerializer
  def project_subscribers
    object.donors
  end
  def project_documents
    object.project_documents
  end

end

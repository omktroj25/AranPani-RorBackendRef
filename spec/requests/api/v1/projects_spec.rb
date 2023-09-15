require 'rails_helper'

RSpec.describe "Api::V1::Projects", type: :request do
  let!(:user) {create:user}
  let!(:application) {create:doorkeeper_application}
  let!(:access_token) {create:doorkeeper_access_token,resource_owner_id:user.id,application:application}

  let!(:project) {create:project}
  let!(:project_document) {create:project_document,project:project}
  let(:image) {build:image,imageable_type:"Activity"}
  let(:project_image) {build:image}
  let(:activity) {build:activity,project:project}

  let!(:seq) {create:sequence_generator,model:"project"}
  before(:each) do
    activity.save
    image.imageable=activity
    image.save
    project_image.imageable=project
    project_image.save
  end
  describe "GET /show" do
    it "validates the return results" do
      get "/api/v1/projects/#{project.id}",headers:{"Authorization":"Bearer "+access_token.token}
      expect(response).to have_http_status(200)
      @response=JSON.parse(response.body)
      expect(@response).to have_key("incharge_name")
      expect(@response).to have_key("status")
      expect(@response).to have_key("project_documents")
      expect(@response).to have_key("activities")
      expect(@response).to have_key("images")
    end
  end
  describe "POST /create" do
    it "validates the creation of project" do
      post "/api/v1/projects",headers:{"Authorization":"Bearer "+access_token.token},params:{"project":{
        "temple_name":"raja proposed temple",
        "incharge_name":"Ranjith",
        "phonenumber":"91919191919",
        "location":"Erode",
        "status":"Proposed",
        "latitude":12.977430,
        "longitude":80.240226
    }}
      expect(response).to have_http_status(200)
      @response=JSON.parse(response.body)
      expect(Project.count).to be(2)
      expect(@response["temple_name"]).to eq("raja proposed temple")
      expect(@response["status"]).to eq("Proposed")
    end
  end
  describe "PUT /update" do
    it "validates the updation of project details" do
      put "/api/v1/projects/#{project.id}",headers:{"Authorization":"Bearer "+access_token.token},params:{"project":{
        "incharge_name":"Vishal"
    }}
      expect(response).to have_http_status(200)
      @response=JSON.parse(response.body)
      expect(@response["incharge_name"]).to eq("Vishal")
      project.reload
      expect(project.incharge_name).to eq("Vishal")
    end
  end
  describe "POST /project_images" do
    it "add project images to project" do
      post "/api/v1/projects/#{project.id}/project_images",headers:{"Authorization":"Bearer "+access_token.token},params:{"image_url":"user defined imgage"}
      expect(response).to have_http_status(200)
      @response=JSON.parse(response.body)
      expect(@response["images"].length).to eq(2)
      expect(@response["images"][1]["image_url"]).to eq("user defined imgage")
    end
  end
  describe "POST /project_documents" do
    it "add project documents to project" do
      post "/api/v1/projects/#{project.id}/project_documents",headers:{"Authorization":"Bearer "+access_token.token},params:{"document_url":"user defined document_url"}
      expect(response).to have_http_status(200)
      @response=JSON.parse(response.body)
      expect(@response["project_documents"].length).to eq(2)
      expect(@response["project_documents"][1]["document_url"]).to eq("user defined document_url")
      project.reload
      expect(project.project_documents.length).to eq(2)
    end
  end
  describe "POST /project_activity" do
    it "checks the addition of activty images for proposed project" do
      post "/api/v1/projects/#{project.id}/project_activity",headers:{"Authorization":"Bearer "+access_token.token},params:{"image_url":"user defined document_url","description":"Project about to begin from january"}
      expect(response).to have_http_status(200)
      @response=JSON.parse(response.body)
      expect(@response["status"]).to eq(false)
      expect(@response["message"]).to eq("Planned project can't have activity")
    end
    it "checks the addition of activty images for active project" do
      project.status=Project.statuses[:Active]
      project.save
      post "/api/v1/projects/#{project.id}/project_activity",headers:{"Authorization":"Bearer "+access_token.token},params:{"image_url":"user defined image_url","description":"Project about to begin from january"}
      expect(response).to have_http_status(200)
      @response=JSON.parse(response.body)
      expect(@response["activities"].length).to eq(2)
      expect(@response["activities"][1]["images"][0]["image_url"]).to eq("user defined image_url")
      project.reload
      expect(project.activities.length).to eq(2)
      expect(project.activities[1].images[0].imageable_type).to eq("Activity")
    end
  end

end
 
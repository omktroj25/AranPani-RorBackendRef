require 'rails_helper'

RSpec.describe "Meta::Donors", type: :request do
  let!(:user) {create:user}
  let!(:application) {create:doorkeeper_application}
  let!(:access_token) {create:doorkeeper_access_token,resource_owner_id:user.id,application:application}

  let(:donor1) {create:donor,role:Donor.roles[:group_head]}
  let!(:donor_user1) {create:donor_user,donor:donor1}

  describe "GET /find" do
    it "find the donor via mobile number" do
      get "/api/v1/donors/find",headers:{"Authorization":"Bearer "+access_token.token},params:{"field":"phonenumber","value":"892982128"}
      expect(response).to have_http_status(200)
      @response=JSON.parse(response.body)
      expect(@response.length).to eq(1)
      expect(@response[0]["name"]).to eq("Ranjith")
    end
    it "find the donor via invalid mobile number" do
      get "/api/v1/donors/find",headers:{"Authorization":"Bearer "+access_token.token},params:{"field":"phonenumber","value":"892982120"}
      expect(response).to have_http_status(200)
      @response=JSON.parse(response.body)
      expect(@response["status"]).to eq(false)
      expect(@response["message"]).to eq("Donor not found")
    end
  end
end

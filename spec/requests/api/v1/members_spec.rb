require 'rails_helper'

RSpec.describe "Api::V1::Members", type: :request do
  let!(:user) {create:user}
  let!(:application) {create:doorkeeper_application}
  let!(:access_token) {create:doorkeeper_access_token,resource_owner_id:user.id,application:application}
  let(:donor1) {create:donor,role:Donor.roles[:group_head]}
  
  let!(:donor_user1) {create:donor_user,donor:donor1}
  
  let!(:seq) {create:sequence_generator}
  let!(:subscription) {create:subscription}
  let!(:subscription2) {create:subscription,no_of_months:3,amount:300}
  let!(:family) {build:family,head:donor1}
  let!(:donor3) {create:donor}
  let!(:donor_user3) {create:donor_user,phonenumber:"2222222222",donor:donor3}
  let(:donor2) {create:donor,role:Donor.roles[:group_member]}
  let!(:donor_user2) {create:donor_user,phonenumber:"98282178278",donor:donor2}
  # let(:donor4) {create:donor}
  # let!(:donor_user4) {create:donor_user,phonenumber:"4444444444444444444",donor:donor4}
  before(:each) do
        family.donors.push(donor1)
        family.donors.push(donor2)
        family.save
  end
  describe "GET /members" do
    it "displays the members of family" do
      get api_v1_donor_members_path(donor1.id),headers:{"Authorization":"Bearer "+access_token.token}
      expect(response).to have_http_status(200)
      @response=JSON.parse(response.body)
      expect(@response["donors"].length).to eq(1)
    end
  end
  describe "POST /members" do
    
    it "Create a new family and add member to the family" do 
      post api_v1_donor_members_path(donor3.id),headers:{"Authorization":"Bearer "+access_token.token},params:{"name":"omprakash","phonenumber":"111111111"}
      expect(response).to have_http_status(200)
      @response=JSON.parse(response.body)
      expect(@response["head"]["id"]).to eq(donor3.id)
      expect(@response["head"]["role"]).to eq("group_head")
      expect(@response["donors"].length).to eq(1)
      expect(@response["subscription"]["id"]).to eq(donor3.donor_subscription.subscription.id)
      expect(@response["donors"][0]["donor_user"]["is_onboarded"]).to eq(false)
    end
    it "create a new family and add existing group head to the family" do
      post api_v1_donor_members_path(donor3.id),headers:{"Authorization":"Bearer "+access_token.token},params:{"id":donor1.id}
      expect(response).to have_http_status(200)
      @response=JSON.parse(response.body)
      expect(@response["head"]["id"]).to eq(donor3.id)
      expect(@response["head"]["role"]).to eq("group_head")
      expect(@response["id"]).to eq(Donor.find(donor1.id)["family_id"])
      expect(@response["donors"].length).to eq(2)
      expect(@response["subscription"]["id"]).to eq(donor3.donor_subscription.subscription.id)
    end
    it "add exixting donor to the family" do
      post api_v1_donor_members_path(donor1.id),headers:{"Authorization":"Bearer "+access_token.token},params:{"id":donor3.id}
      expect(response).to have_http_status(200)
      @response=JSON.parse(response.body)
      expect(@response["head"]["id"]).to eq(donor1.id)
      expect(@response["head"]["role"]).to eq("group_head")
      expect(@response["id"]).to eq(Donor.find(donor3.id)["family_id"])
      expect(@response["donors"].length).to eq(2)
      expect(@response["subscription"]["id"]).to eq(donor1.family.subscription.id)
    end

  end
  describe "PUT /promote_head" do
    it "promotes the group member to be the group head" do
      put promote_head_api_v1_donor_member_path(donor1.id,donor2.id),headers:{"Authorization":"Bearer "+access_token.token}
      expect(response).to have_http_status(200)
      @response=JSON.parse(response.body)
      # debugger
      expect(@response["head"]["id"]).to eq(donor2.id)
      expect(Donor.find(donor1.id).role).to eq("group_member")
      expect(Donor.find(donor2.id).role).to eq("group_head")
    end
  end
  describe "PUT /promote_donor" do
    it "promotes the group member to be the individual donor" do
      put promote_donor_api_v1_donor_member_path(donor1.id,donor2.id),headers:{"Authorization":"Bearer "+access_token.token}
      expect(response).to have_http_status(200)
      @response=JSON.parse(response.body)
      expect(Donor.find(donor2.id)["role"]).to eq("individual_donor")
      expect(Donor.find(donor1.id).family.donors.length).to eq(1)
    end
  end
end

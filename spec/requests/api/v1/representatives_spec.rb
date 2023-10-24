require 'rails_helper'

RSpec.describe "Api::V1::Representatives", type: :request do
  let!(:user) {create:user}
  let!(:application) {create:doorkeeper_application}
  let!(:access_token) {create:doorkeeper_access_token,resource_owner_id:user.id,application:application}
  let!(:donor1) {create:donor,is_area_representative:true}
  let!(:donor2) {create:donor}
  let!(:donor_user1) {create:donor_user,donor:donor1}
  let!(:donor_user2) {create:donor_user,phonenumber:"98282178278",name:"vishal",donor:donor2}
  let!(:donor3) {create:donor}
  let!(:donor_user3) {create:donor_user,donor:donor3,phonenumber:"12121212122",name:"omprakash"}
  let!(:seq) {create:sequence_generator}
  let!(:subscription) {create:subscription}
  let!(:subscription2) {create:subscription,no_of_months:3,amount:300}
  let(:family) {build:family,head:donor1}
  let!(:payment) {create:payment,is_one_time_payment:true,donor:donor1,area_representative:donor1.area_representative,subscription:donor1.donor_subscription.subscription}
  before(:each) do
    donor1.area_representative=donor1
    donor1.save
    donor2.area_representative=donor1
    donor2.save
  end
  describe "GET /representatives" do
    it "gets all representatives" do
      get "/api/v1/representatives",headers:{"Authorization":"Bearer "+access_token.token}
      expect(response).to have_http_status(200)
      @response=JSON.parse(response.body)
      expect(@response.length).to eq(1)
      expect(@response[0]).to have_key('id')
    end
  end
  describe "UPADTE /representatives" do
    it "updates the area reps for all provided donor ids" do
      put "/api/v1/representatives/#{donor1.id}",headers:{"Authorization":"Bearer "+access_token.token},params:{"donor_ids":[donor3.id]}
      expect(response).to have_http_status(200)
      @response=JSON.parse(response.body)
      expect(@response["donators"].length).to eq(2)
      donor3.reload
      expect(donor3.area_representative_id).to eq(donor1.id)
    end
  end
  describe "GET /representatives/:id" do
    it "shows the specific representative" do
      get "/api/v1/representatives/#{donor1.id}",headers:{"Authorization":"Bearer "+access_token.token}
      expect(response).to have_http_status(200)
      @response=JSON.parse(response.body)
      expect(@response).to have_key("donators")
      expect(@response).to have_key("donor_subscription")
      expect(@response).to have_key("donor_user")
    end
  end
end

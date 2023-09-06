require 'rails_helper'

RSpec.describe "Api::V1::Representatives", type: :request do
  let!(:user) {create:user}
  let!(:application) {create:doorkeeper_application}
  let!(:access_token) {create:doorkeeper_access_token,resource_owner_id:user.id,application:application}
  let!(:donor1) {create:donor,is_area_representative:true}
  let!(:donor2) {create:donor}
  let!(:donor_user1) {create:donor_user,donor:donor1}
  let!(:donor_user2) {create:donor_user,phonenumber:"98282178278",name:"vishal",donor:donor2}
  let!(:seq) {create:sequence_generator}
  let!(:subscription) {create:subscription}
  let!(:subscription2) {create:subscription,no_of_months:3,amount:300}
  let(:family) {build:family,head:donor1}
  let!(:donor_subscription_history) {create:donor_subscription_history,donor_subscription:donor1.donor_subscription,subscription:donor1.donor_subscription.subscription}
  let!(:payment) {create:payment,is_one_time_payment:true,donor:donor1,area_representative:donor1.area_representative,donor_subscription_history:donor_subscription_history}
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
      expect(@response[0]["donators"].length).to eq(1)
    end
  end
end

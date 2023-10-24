require 'rails_helper'

RSpec.describe "Api::V1::Dashboards", type: :request do
  let!(:user) {create:user}
  let!(:application) {create:doorkeeper_application}
  let!(:access_token) {create:doorkeeper_access_token,resource_owner_id:user.id,application:application}
  let!(:donor1) {create:donor,is_area_representative:true}
  let!(:donor2) {create:donor,area_representative:donor1}
  let!(:donor3) {build:donor,is_area_representative:true}
  let!(:donor_user1) {create:donor_user,donor:donor1}
  let!(:donor_user2) {create:donor_user,phonenumber:"98282178278",name:"vishal",donor:donor2}
  let!(:donor_user3) {build:donor_user,phonenumber:"98282178279",name:"aakash",donor:donor3}
  let!(:seq) {create:sequence_generator}
  let!(:subscription) {create:subscription}
  let!(:subscription2) {create:subscription,no_of_months:3,amount:300}
  let(:family) {build:family,head:donor1}

  let!(:payment) {create:payment,donor:donor1,area_representative:donor1.area_representative,subscription:donor1.donor_subscription.subscription}
  let(:family_history) {build:family_history,donor_id:donor1.id}
  let(:payment1) {build:payment,donor:donor1,area_representative:donor1.area_representative}
  let!(:project) {create:project}
  let!(:project_document) {create:project_document,project:project}
  let(:image) {build:image,imageable_type:"Activity"}
  let(:project_image) {build:image}
  let(:activity) {build:activity,project:project}

  let!(:seq) {create:sequence_generator,model:"project"}

  describe "GET /dashboard_stats" do
    it "validates the dashboard stats results" do
      get "/api/v1/dashboard_stats",headers:{"Authorization":"Bearer "+access_token.token}
      expect(response).to have_http_status(200)
      @response=JSON.parse(response.body)
      expect(@response).to have_key('project_stats')
      expect(@response).to have_key('donor_stats')
      expect(@response).to have_key('rep_stats')
      expect(@response).to have_key('user_stats')
      expect(@response["donor_stats"]).to have_key('Active')
      expect(@response["donor_stats"]).to have_key('InActive')
      expect(@response["donor_stats"]).to have_key('total_donors')
      expect(@response["project_stats"]).to have_key('Proposed')
      expect(@response["rep_stats"]).to have_key('Active')
      expect(@response["rep_stats"]).to have_key('InActive')
      expect(@response["rep_stats"]).to have_key('total_reps')
    end
  end
  describe "GET /donation_stats" do
    it "validates the result of donation stats" do
      get "/api/v1/donation_stats?year=2023",headers:{"Authorization":"Bearer "+access_token.token}
      expect(response).to have_http_status(200)
      @response=JSON.parse(response.body)
      @response=@response["donation_stats"]
      expect(@response).to have_key('09')
      expect(@response["09"]).to have_key('online_payment')
      expect(@response["09"]).to have_key('offline_payment')
      expect(@response["09"]).to have_key('one_time_payment')
      expect(@response["09"]).to have_key('total_payment')
    end
  end
end

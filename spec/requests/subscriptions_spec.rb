require 'rails_helper'

RSpec.describe "Subscriptions", type: :request do
  let!(:user) {create:user}
  let!(:application) {create:doorkeeper_application}
  let!(:access_token) {create:doorkeeper_access_token,resource_owner_id:user.id,application:application}
  describe "GET /subscriptions" do
    it "Return all the subscription plans" do
      FactoryBot.create_list(:subscription, 4)
      get api_v1_subscriptions_path,headers:{"Authorization":"Bearer "+access_token.token}
      expect(JSON.parse(response.body).length).to eq(4)
      expect(response).to have_http_status(200)
    end
  end
  describe "PUT /subscriptions/:id" do
    let!(:subscription) {create:subscription}
    it "Deactivate the subscription" do
      put api_v1_subscription_path(subscription.id),headers:{"Authorization":"Bearer "+access_token.token},params:{status:false}
      expect(Subscription.count).to eq(1)
      expect(JSON.parse(response.body)["status"]).to eq("success")
      expect(response).to have_http_status(200)

    end
  end
end
 
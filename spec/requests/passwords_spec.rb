require 'rails_helper'

RSpec.describe "Passwords", type: :request do
  let!(:user) {create:user}
  let!(:application) {create:doorkeeper_application}
  let!(:access_token) {create:doorkeeper_access_token,resource_owner_id:user.id,application:application}
  describe "POST /password/forgot" do
    let!(:user1) {create:user,email:"vishal@gamil.com",role:User.roles[:user]}
    it "validating forgot password" do
      post forgot_api_v1_password_index_path,headers:{"Authorization":"Bearer "+access_token.token},params:{email:user1.email}
      user2=User.find(user1.id)
      expect(JSON.parse(response.body)["token"]).to eq(user2.reset_password_token)
      expect(response).to have_http_status(200)
    end
  end
  describe "POST /password/:id/reset" do
    let!(:user1) {create:user,email:"vishal@gamil.com",role:User.roles[:user]}
    it "resetting a password for the user" do
      post forgot_api_v1_password_index_path,headers:{"Authorization":"Bearer "+access_token.token},params:{email:user1.email}
      user2=User.find(user1.id)
      post reset_api_v1_password_path(user2.reset_password_token),headers:{"Authorization":"Bearer "+access_token.token},params:{password:"123456789"}
      expect(JSON.parse(response.body)["status"]).to eq("success")
      expect(response).to have_http_status(200)
    end
  end
end

require 'rails_helper'

RSpec.describe "Users", type: :request do
  let!(:user) {create:user}
  let!(:application) {create:doorkeeper_application}
  let!(:access_token) {create:doorkeeper_access_token,resource_owner_id:user.id,application:application}
  describe "POST /users" do
    it "Expects ok status for successfull creation of users" do
      post api_v1_internal_users_path,headers:{"Authorization":"Bearer "+access_token.token},params:{internal_user:{
        "phonenumber": "9842840700",
        "status": true,
        "email": "karthikeya@gmail.com",
        "username": "karthikeya",
        "permissions_attributes": [
            {
                "scope": "Donors"
            },
            {
                "scope": "Payments"
            }
        ]
    }}
      expect(response).to have_http_status(200)
      expect(User.count).to be(2)
    end
    it "Expects validation error for creation of users" do
      response= post api_v1_internal_users_path,headers:{"Authorization":"Bearer "+access_token.token},params:{internal_user:{
        "phonenumber": "9842840700",
        "status": true,
        "email": "ranjithvel2001@gmail.com",
        "username": "karthikeya",
        "permissions_attributes": [
            {
                "scope": "Donors"
            },
            {
                "scope": "Payments"
            }
        ]
    }}
      expect(response).to be(422)
      expect(User.count).to be(1)
    end
  end
  describe "UPDATE /users" do
    let!(:user1) {create:user,email:"vishal@gmail.com"}
    it "update the existing user" do
      put api_v1_internal_user_path(user1.id),headers:{"Authorization":"Bearer "+access_token.token},params:{internal_user:{
        "phonenumber":"9976724400"
      }}
      expect(JSON.parse(response.body)["phonenumber"]).to eq("9976724400")
      expect(response).to have_http_status(200)
    end
  end
  describe "DESTROY /users" do
    let!(:user1) {create:user,email:"vishal@gmail.com",role:User.roles[:user]}
    it "check the dependent destroy" do
      user1.permissions.push(Permission.new(scope:"Donors"))
      user1.save!
      delete api_v1_internal_user_path(user1.id),headers:{"Authorization":"Bearer "+access_token.token}
      expect(User.count).to be(1)
      expect(Permission.count).to be(0)
    end
  end
  describe "GET /users/:id" do
    it "checks whether the user details are displaying" do
      get api_v1_internal_users_path(user.id),headers:{"Authorization":"Bearer "+access_token.token}
      expect(JSON.parse(response.body)[0]["email"]).to eq("ranjithvel2001@gmail.com")
      expect(response).to have_http_status(200)
    end
  end

end

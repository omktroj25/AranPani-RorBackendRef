require 'rails_helper'

RSpec.describe "Api::V1::Payments", type: :request do
  let!(:user) {create:user}
  let!(:application) {create:doorkeeper_application}
  let!(:access_token) {create:doorkeeper_access_token,resource_owner_id:user.id,application:application}
  let!(:donor1) {create:donor}
  let!(:donor2) {create:donor}
  let!(:donor_user1) {create:donor_user,donor:donor1}
  let!(:donor_user2) {create:donor_user,phonenumber:"98282178278",name:"vishal",donor:donor2}
  let!(:seq) {create:sequence_generator}
  let!(:subscription) {create:subscription}
  let!(:subscription2) {create:subscription,no_of_months:3,amount:300}
  let(:family) {build:family,head:donor1}
  let!(:payment) {create:payment,is_one_time_payment:true,donor:donor1,area_representative:donor1.area_representative,subscription:donor1.donor_subscription.subscription}
  describe "POST /payment" do
    it "creates a new one time payment" do
      post api_v1_payments_path,headers:{"Authorization":"Bearer "+access_token.token},params:{
        "donor": {
            "donor_user_attributes": {
                "name": "Aaakash",
                "age": 21,
                "phonenumber": "919191929221",
                "email": "aakash@gmail.com",
                "guardian_name": "shjahjh",
                "country": "india",
                "pincode": "638183",
                "address": "dsdsadsd dsd",
                "gender": "male",
                "id_card": "Aadhar",
                "id_card_value": "32392378vv",
                "pan": "sdsd234434",
                "is_onboarded": false
            },
            "status": true
        },
        "payments": {
            "transaction_id": "189291fd",
            "amount": 90000,
            "is_one_time_payment": true,
            "settled": true,
            "mode": "online"
        }
    }
    expect(response).to have_http_status(200)
    @response=JSON.parse(response.body)
    expect(@response.length).to eq(1)
    expect(@response[0]).to have_key("is_one_time_payment")
    expect(@response[0]).to have_key("amount")
    end
  end
  describe "GET /payments" do
    it "checks the return results of the index api" do
      get "/api/v1/payments?is_one_time_payment=true&month=Sep&year=2023",headers:{"Authorization":"Bearer "+access_token.token}
      expect(response).to have_http_status(200)
      @response=JSON.parse(response.body)
      expect(@response["payments"].length).to eq(1)
      expect(@response["payments"][0]).to have_key("payment_date")
      expect(@response["payments"][0]).to have_key("amount")
      expect(@response["payments"][0]).to have_key("donor")
    end
    it "checks the return reults based on filtering" do
      get "/api/v1/payments?is_one_time_payment=false&month=Aug&year=2023",headers:{"Authorization":"Bearer "+access_token.token}
      expect(response).to have_http_status(200)
      @response=JSON.parse(response.body)
      expect(@response["payments"].length).to eq(0)
    end
    it "checks the return reults based on all payments filtering" do
      get "/api/v1/payments?month=Sep&year=2023",headers:{"Authorization":"Bearer "+access_token.token}
      expect(response).to have_http_status(200)
      @response=JSON.parse(response.body)
      expect(@response["payments"].length).to eq(1)
    end
  end
end

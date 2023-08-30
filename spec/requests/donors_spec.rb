require 'rails_helper'

RSpec.describe "Donors", type: :request do
  let!(:user) {create:user}
  let!(:application) {create:doorkeeper_application}
  let!(:access_token) {create:doorkeeper_access_token,resource_owner_id:user.id,application:application}
  let!(:donor1) {create:donor}
  let!(:donor2) {create:donor}
  let(:donor_user1) {create:donor_user,donor:donor1}
  let(:donor_user2) {create:donor_user,phonenumber:"98282178278",donor:donor2}
  let!(:seq) {create:sequence_generator}
  let!(:subscription) {create:subscription}
  describe "GET /donors" do
    it "checks the result of index query" do
      donor_user1.save!
      donor_user2.save!
      get api_v1_donors_path,headers:{"Authorization":"Bearer "+access_token.token}
      expect(JSON.parse(response.body).length()).to eq(2)
      expect(response).to have_http_status(200)
    end
  end
  describe "POST /donors" do
    it "checks the creation of new donors" do
      donor_user1.save!
      donor_user2.save!
      p subscription.id
      post api_v1_donors_path,headers:{"Authorization":"Bearer "+access_token.token},params:{"donor":{
        "donor_user_attributes": {
            "phonenumber": "111111111191",
            "name": "Sanjay",
            "email":"vishal@gmail.com",
            "guardian_name": "shjahjh",
            "country": "india",
            "gender": "male",
            "age": 21,
            "pan": "sdsd234434",
            "id_card_value": "32392378vv",
            "id_card": "Aadhar",
            "address": "dsdsadsd dsd",
            "pincode": "638183",
            "is_onboarded": true
        },
        "donor_subscription_attributes":{
            "subscription_id": subscription.id,
            "last_updated":false
        },
        "is_area_representative": false,
        "status": true,
        "role": "individual_donor"
    }}
    expect(Donor.count).to be(3)
    expect(response).to have_http_status(200)
    end
  end
  describe "PUT /donors" do
    it "updates the donor details" do
      donor_user1.save!
      put api_v1_donor_path(donor1.id),headers:{"Authorization":"Bearer "+access_token.token},params:{"donor":{
        "donor_user_attributes": {
          "id":donor_user1.id,
            "phonenumber": "111111111191",
            "name": "gourav",
            "email":"gourav@gmail.com",
            "guardian_name": "shjahjh",
            "country": "india",
            "gender": "male",
            "age": 21,
            "pan": "sdsd234434",
            "id_card_value": "32392378vv",
            "id_card": "Aadhar",
            "address": "dsdsadsd dsd",
            "pincode": "638183",
            "is_onboarded": true
        },
        "id":donor1.id,
        "is_area_representative": false,
        "status": true,
        "role": "individual_donor"
    }}
      expect(JSON.parse(response.body)["id"]).to eq(donor1.id)
      expect(JSON.parse(response.body)["donor_user"]["name"]).to eq("gourav")
      expect(JSON.parse(response.body)["donor_user"]["email"]).to eq("gourav@gmail.com")
      
    end
  end
end

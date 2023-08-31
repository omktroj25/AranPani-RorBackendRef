require 'rails_helper'

RSpec.describe "Donors", type: :request do
  let!(:user) {create:user}
  let!(:application) {create:doorkeeper_application}
  let!(:access_token) {create:doorkeeper_access_token,resource_owner_id:user.id,application:application}
  let!(:donor1) {create:donor}
  let!(:donor2) {create:donor}
  let!(:donor_user1) {create:donor_user,donor:donor1}
  let!(:donor_user2) {create:donor_user,phonenumber:"98282178278",donor:donor2}
  let!(:seq) {create:sequence_generator}
  let!(:subscription) {create:subscription}
  let!(:subscription2) {create:subscription,no_of_months:3,amount:300}
  let(:family) {build:family,head:donor1}
  before(:each) do
    @donor={"donor":{
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
  end
  describe "GET /donors" do
    it "checks the result of index query" do
      get api_v1_donors_path,headers:{"Authorization":"Bearer "+access_token.token}
      expect(response).to have_http_status(200)
      @response=JSON.parse(response.body)
      expect(@response.length()).to eq(2)
      expect(@response[0]).to have_key("donor_reg_no")
      expect(@response[0]).to have_key("status")
      expect(@response[0]).to have_key("area_representative_id")
      expect(@response[0]).to have_key("donor_user")
      expect(@response[0]["donor_user"]).to have_key("name")
      expect(@response[0]["donor_user"]).to have_key("phonenumber")
      expect(@response[0]["donor_user"]).to have_key("email")
    end
  end
  describe "POST /donors" do
    it "checks the creation of new donors" do
      post api_v1_donors_path,headers:{"Authorization":"Bearer "+access_token.token},params:@donor
    expect(Donor.count).to be(3)
    expect(response).to have_http_status(200)
    end
    it "checks the validation of name field in donor" do
      @donor[:donor][:donor_user_attributes].delete(:name)
      post api_v1_donors_path,headers:{"Authorization":"Bearer "+access_token.token},params:@donor
      expect(Donor.count).to be(2)
      expect(JSON.parse(response.body)["donor_user.name"][0]).to eq("can't be blank")
    end
    it "checks the validation of phonenumber field in donor" do
      @donor[:donor][:donor_user_attributes][:phonenumber]="98282178278"
      post api_v1_donors_path,headers:{"Authorization":"Bearer "+access_token.token},params:@donor
      expect(Donor.count).to be(2)
      expect(JSON.parse(response.body)["donor_user.phonenumber"][0]).to eq("has already been taken")
    end
  end
  describe "PUT /donors" do
    it "updates the donor details" do
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
  describe "PUT /subscription" do
    it "updates the donor subscription" do
      
      put subscription_api_v1_donor_path(donor1.id),headers:{"Authorization":"Bearer "+access_token.token},params:{"subscription_id":subscription2.id}
      expect(response).to have_http_status(200)
      @response=JSON.parse(response.body)
      expect(@response["donor_subscription"]["subscription"]["id"]).to eq(subscription2.id)
    end
    describe "Checks the endpoints for family donors" do
      before(:each) do
        family.save
        donor1.family=family
        donor1.role=Donor.roles[:group_head]
        donor2.family=family
        donor2.role=Donor.roles[:group_member]
        donor1.save
        donor2.save
      end
      it "updates the family subscription" do
        put subscription_api_v1_donor_path(donor1.id),headers:{"Authorization":"Bearer "+access_token.token},params:{"subscription_id":subscription2.id}
        expect(response).to have_http_status(200)
        @response=JSON.parse(response.body)
        expect(@response["subscription"]["id"]).to eq(subscription2.id)
      end
      it "updates the family subscription through group member" do
        put subscription_api_v1_donor_path(donor2.id),headers:{"Authorization":"Bearer "+access_token.token},params:{"subscription_id":subscription2.id}
        expect(response).to have_http_status(422)
        @response=JSON.parse(response.body)
        expect(@response["status"]).to eq("Update the subscription through your group head")
      end
      it "validates the promotion of donor to area_representative as a group head" do
        put promote_rep_api_v1_donor_path(donor1.id),headers:{"Authorization":"Bearer "+access_token.token}
        expect(response).to have_http_status(200)
        @response=JSON.parse(response.body)
        expect(@response["area_representative_id"]).to eq(donor1.id)
        expect(@response["is_area_representative"]).to eq(true)
        expect(Donor.find(donor2.id)["area_representative_id"]).to eq(donor1.id)
      end
    end
  end
  describe "PUT /deactivate" do
    it "deactivates the user" do
      put deactivate_api_v1_donor_path(donor1.id),headers:{"Authorization":"Bearer "+access_token.token},params:{"status":false}
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["status"]).to eq(false)
    end
  end
  describe "PUT /promote_rep" do
    it "validates the promotion of donor to area_representative" do
      put promote_rep_api_v1_donor_path(donor1.id),headers:{"Authorization":"Bearer "+access_token.token}
      expect(response).to have_http_status(200)
      @response=JSON.parse(response.body)
      expect(@response["area_representative_id"]).to eq(donor1.id)
      expect(@response["is_area_representative"]).to eq(true)
    end
  end
end

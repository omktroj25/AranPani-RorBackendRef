require 'rails_helper'

RSpec.describe "Donors", type: :request do
  let!(:user) {create:user}
  let!(:application) {create:doorkeeper_application}
  let!(:access_token) {create:doorkeeper_access_token,resource_owner_id:user.id,application:application}
  let!(:donor1) {create:donor}
  let!(:donor2) {create:donor}
  let(:donor3) {build:donor,is_area_representative:true}
  let!(:donor_user1) {create:donor_user,donor:donor1}
  let!(:donor_user2) {create:donor_user,phonenumber:"98282178278",name:"vishal",donor:donor2}
  let(:donor_user3) {build:donor_user,phonenumber:"98282178279",name:"aakash",donor:donor3}
  let!(:seq) {create:sequence_generator}
  let!(:subscription) {create:subscription}
  let!(:subscription2) {create:subscription,no_of_months:3,amount:300}
  let(:family) {build:family,head:donor1}
  let!(:donor_subscription_history) {create:donor_subscription_history,donor_subscription:donor1.donor_subscription,subscription:donor1.donor_subscription.subscription}
  let!(:payment) {create:payment,donor:donor1,area_representative:donor1.area_representative,donor_subscription_history:donor_subscription_history}
  let(:family_history) {build:family_history,donor_id:donor1.id}
  let(:payment1) {build:payment,donor:donor1,area_representative:donor1.area_representative}
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
  }
}
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
    describe "deactivates for area representatives" do
      before(:each) do
        donor1.is_area_representative=true
        donor1.area_representative_id=donor1.id
        donor1.save
        donor2.area_representative_id=donor1.id
        donor2.save
      end
    it "deactivates the area representative" do
      put deactivate_api_v1_donor_path(donor1.id),headers:{"Authorization":"Bearer "+access_token.token},params:{"status":false}
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["status"]).to eq("no nearby area representatives found")
    end
    describe "creates new area rep" do
      let!(:donor3) {create:donor,is_area_representative:true}
    let!(:donor_user3) {create:donor_user,donor:donor3,phonenumber:"222222222",latitude:12.968144, longitude:80.234310}
    before(:each) do
      donor3.area_representative_id=donor3.id
    donor3.save
    end
    it "deactivates area rep and assigns a new rep nearby location" do
        put deactivate_api_v1_donor_path(donor1.id),headers:{"Authorization":"Bearer "+access_token.token},params:{"status":false}
        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)["status"]).to eq(false)
        expect(Donor.find(donor2.id).area_representative_id).to eq(donor3.id)
        expect(Donor.find(donor3.id).donators.length).to eq(3)
    end
    end
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
  describe "GET /show" do
    before(:each) do
      family.donors.push(donor1)
      family.donors.push(donor2)
      family.save
    end
    it "validates the return results of the show api" do
      get api_v1_donor_path(donor1.id),headers:{"Authorization":"Bearer "+access_token.token}
      expect(response).to have_http_status(200)
      @response=JSON.parse(response.body)
      expect(@response).to have_key("role")
      expect(@response).to have_key("status")
      expect(@response).to have_key("area_representative_id")
      expect(@response).to have_key("group_head")
      expect(@response).to have_key("donor_subscription")
      expect(@response).to have_key("donor_user")
      expect(@response["donor_user"]).to have_key("name")
      expect(@response["donor_user"]).to have_key("email")
      expect(@response["donor_user"]).to have_key("phonenumber")
    end
  end
  describe "GET /donors/:id/payments" do
    before(:each) do
      family_history.donors.push(donor1)
      family_history.donors.push(donor2)
      family.save
      family_history.subscription=family.subscription
      family_history.save!
      payment1.family_history=family_history
      payment1.save

    end
    
    it "get all the payments of the donors" do
      get payments_api_v1_donor_path(donor1.id),headers:{"Authorization":"Bearer "+access_token.token}
      expect(response).to have_http_status(200)
      @response=JSON.parse(response.body)
      expect(@response).to have_key("stats")
      expect(@response).to have_key("payments")
      expect(@response["payments"].length).to eq(2)
      expect(@response["payments"][1]["group_members"].length).to eq(1)
      expect(@response["payments"][1]["count"]).to eq(2)
    end
  end
  describe "POST /representatives" do
    it "demote an area representative" do
      donor1.is_area_representative=true
      donor1.area_representative=donor1
      donor1.save!
      donor2.area_representative=donor1
      donor2.save
      donor3.area_representative=donor3
      donor3.save
        put demote_rep_api_v1_donor_path(donor1.id),headers:{"Authorization":"Bearer "+access_token.token},params:{"representative_id":donor3.id}
        expect(response).to have_http_status(200)
        @response=JSON.parse(response.body)
        expect(@response["donators"].length).to eq(2)
        expect(Donor.find(donor2.id).area_representative_id).to eq(donor3.id)
    end
  end
  describe "PUT /settle_payment" do
    it "settle the payment to the trust" do
      put "/api/v1/donors/#{donor1.id}/payments/#{payment.id}",headers:{"Authorization":"Bearer "+access_token.token}
      expect(response).to have_http_status(200)
      @response=JSON.parse(response.body)
      expect(@response["settled"]).to eq(true)
      expect(Payment.find(payment.id).settled).to eq(true)
    end
  end
end

 

FactoryBot.define do
    factory :doorkeeper_access_token, class: Doorkeeper::AccessToken do
      application { create(:doorkeeper_application) }
      resource_owner_id { "" }
      expires_in { 7200 }
      scopes { '' }
      token {"abcxyz123980"}
      created_at { Time.now }
    end
  end
  
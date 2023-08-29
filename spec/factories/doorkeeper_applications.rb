FactoryBot.define do
    factory :doorkeeper_application, class: Doorkeeper::Application do
      name { 'Test Application' }
      redirect_uri { '' }
      uid { 'abc123' }
      secret { 'def456' }
      scopes {''}
    end
  end
  
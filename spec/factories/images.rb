FactoryBot.define do
    factory :image do
        image_url {"http://local_image"}
        imageable_type {"Project"}
    end
  end
  
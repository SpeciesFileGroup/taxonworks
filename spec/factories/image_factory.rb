# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :image, class: Image, traits: [:creator_and_updater] do

    factory :valid_image do
      image_file { fixture_file_upload((Rails.root + 'spec/files/images/tiny.png'), 'image/png') }
    end

    factory :weird_image do
      image_file { fixture_file_upload((Rails.root + 'spec/files/images/W3$rd fi(le%=name!.png'), 'image/png') }
    end

    factory :default_image do
      image_file "MyString"
      image_file_file_name "MyString"
    end

  end

end

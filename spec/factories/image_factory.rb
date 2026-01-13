FactoryBot.define do
  factory :image, class: Image, traits: [:creator_and_updater] do

    factory :valid_image do
      image_file { Rack::Test::UploadedFile.new((Rails.root + 'spec/files/images/tiny.png'), 'image/png') }
    end

    factory :weird_image do
      image_file { Rack::Test::UploadedFile.new((Rails.root + 'spec/files/images/W3$rd fi(le%=name!.png'), 'image/png') }
    end

    factory :very_tiny_image do # invalid
      image_file { Rack::Test::UploadedFile.new((Rails.root + 'spec/files/images/very_tiny.png'), 'image/png') }
    end

    factory :tiny_random_image do
      image_file {  Rack::Test::UploadedFile.new(Spec::Support::Utilities::Files.generate_tiny_random_png, 'image/png')   }
    end

  end
end

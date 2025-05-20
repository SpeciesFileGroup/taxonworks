FactoryBot.define do
  factory :sound, traits: [:housekeeping] do
    factory :valid_sound do
      name { Faker::Lorem.unique.word }
      sound_file { Rack::Test::UploadedFile.new((Rails.root + 'spec/files/sounds/sound1.wav'), 'audio/wav') }
    end
  end
end

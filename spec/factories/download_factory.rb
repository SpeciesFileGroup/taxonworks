FactoryBot.define do
  factory :download, class: Download, traits: [:housekeeping] do
    factory :valid_download do
      name { Faker::Lorem.word }
      description { Faker::Lorem.sentence }
      filename { "#{Faker::Lorem.word}.zip" }
      source_file_path { Rails.root.join('spec/files/downloads/Sample.zip') }
      request { "/model/endpoint?params" }
      expires { 2.days.from_now }
      times_downloaded { 0 }
    end
    factory :expired_download do
      name { Faker::Lorem.word }
      description { Faker::Lorem.sentence }
      filename { "#{Faker::Lorem.word}.zip" }
      source_file_path { Rails.root.join('spec/files/downloads/Sample.zip') }
      request { "/model/endpoint?params" }
      expires { 1.second.ago }
      times_downloaded { 0 }
    end
    factory :valid_download_no_file do
      name { Faker::Lorem.word }
      description { Faker::Lorem.sentence }
      filename { "#{Faker::Lorem.word}.zip" }
      request { "/model/endpoint?params" }
      expires { 2.days.from_now }
      times_downloaded { 0 }
    end
  end
end
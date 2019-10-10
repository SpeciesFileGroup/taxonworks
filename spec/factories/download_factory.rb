FactoryBot.define do
  factory :download, class: Download, traits: [:housekeeping] do
    factory :valid_download do
      name { "Sample File" }
      description { "A sample file for testing" }
      filename { "Sample.zip" }
      src_file_path { Rails.root.join('spec/files/downloads/Sample.zip') }
      request { "/model/endpoint?params" }
      expires { 2.days.from_now }
      times_downloaded { 0 }
    end
  end
end
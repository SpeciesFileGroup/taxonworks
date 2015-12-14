FactoryGirl.define do
  factory :documentation, class: Documentation, traits: [:creator_and_updater] do
    factory :valid_documentation do
      image_file { fixture_file_upload((Rails.root + 'spec/files/documents/tiny.png'), 'image/png') }
      type ''
    end
  end
end


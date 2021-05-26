FactoryBot.define do
  factory :extract, traits: [:housekeeping] do
    factory :valid_extract do
      verbatim_anatomical_origin { 'MyString' }
      year_made { Time.now.year }
      month_made { 1 }
      day_made { 1 }
    end
  end
end

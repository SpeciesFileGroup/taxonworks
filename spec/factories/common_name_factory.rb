FactoryBot.define do
  factory :common_name, traits: [:housekeeping]  do
    factory :valid_common_name do
      name 'Purple People Eater'
        association :otu, factory: :valid_otu
      factory :attributed_common_name do
        association :geographic_area, factory: :valid_geographic_area
        association :language, factory: :valid_language
        start_year 1958 
        end_year 2015
      end
    end
  end
end

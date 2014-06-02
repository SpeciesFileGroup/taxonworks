FactoryGirl.define do

  factory :georeference_verbatim_data, class: 'Georeference::VerbatimData', traits: [:housekeeping] do

    factory :valid_georeference_verbatim_data,  aliases: [:my_office] do
      association :collecting_event, factory: :collecting_event_my_office
      association :geographic_item, factory: :valid_geographic_item
      # error_radius 16000 # TODO: This isn't required in valid, abstract
    end

    # 22.times {FactoryGirl.create(:georeference_verbatim_data_with_random_point) }
    factory :georeference_verbatim_data_with_random_point do
      association :geographic_item, factory: :random_point_geographic_item 
      association :collecting_event, factory: :valid_collecting_event 
    end

  end

end

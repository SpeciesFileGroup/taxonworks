FactoryBot.define do

  trait :random_verbatim_label do
    verbatim_label { Utilities::Strings.random_string(8) }
  end

  sequence :verbatim_label do |n|
    "Label #{n} for testing..."
  end

  sequence :verbatim_locality do |n|
    "Locality #{n} for testing..."
  end

  factory :collecting_event, traits: [:housekeeping] do
    factory :valid_collecting_event_sans_lat_long do
      verbatim_locality
      verbatim_latitude { nil }
      verbatim_longitude { nil }
      verbatim_elevation { nil }
    end

    factory :valid_collecting_event do
      verbatim_locality
      verbatim_latitude { '40.116402' }
      verbatim_longitude { '-88.243386' }
      verbatim_elevation { '735' }

      factory :random_collecting_event, traits: [:random_verbatim_label]

    end

    # !! Need an after to set the verbatim values off of the generated values!!
    factory :collecting_event_with_random_point_georeference do
      association :verbatim_georeference, factory: :georeference_verbatim_data_with_random_point
    end

    factory :collecting_event_my_office do
      verbatim_locality { 'Champaign Co., Illinois' }
      verbatim_label { "USA:IL:Champaign Co.\nUniversity of Illinois\nResearch Park\nEvers Lab\n1909 S. Oak St.\nRoom 2024" }
      minimum_elevation { 757 }
      verbatim_latitude { '40.091655' }
      verbatim_longitude { '-88.241413' }
    end

    factory :collecting_event_point_c do
      verbatim_locality { 'Champaign Co., Illinois' }
      verbatim_label { 'City of Champaign' }
      minimum_elevation { 735 }
      verbatim_latitude { '40.116402' }
      verbatim_longitude { '-88.243386' }
    end

    factory :collecting_event_point_u do
      verbatim_locality { 'Champaign Co., Illinois' }
      verbatim_label { 'Urbana City Building' }
      minimum_elevation { 726 }
      verbatim_latitude { '40.110037' }
      verbatim_longitude { '-88.204517' }
    end

    factory :collecting_event_without_verbatim_locality do
      verbatim_latitude { '40.116402' }
      verbatim_longitude { '-88.243386' }
      verbatim_elevation { '735' }
    end

  end
end

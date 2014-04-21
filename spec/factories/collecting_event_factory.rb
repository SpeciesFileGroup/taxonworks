FactoryGirl.define do

  sequence :verbatim_label do |n|
    "Label #{n} for testing..."
  end

  sequence :verbatim_locality do |n|
    "Locality #{n} for testing..."
  end

  factory :collecting_event, traits: [:housekeeping] do

    factory :valid_collecting_event do
      verbatim_label # is not required for validity
      verbatim_locality
      # verbatim_label "USA:TX:Brazos Co.\nCollege Station-#{label_maker}\nLick Creek Park\nii.15.1975 YPT"
      # minimum_elevation 735 # ,
      # verbatim_label { label_maker }
    end

    factory :collecting_event_my_office do
      verbatim_locality 'Champaign Co., Illinois'
      verbatim_label "USA:IL:Champaign Co.\nUniversity of Illinois\nResearch Park\nEvers Lab\n1909 S. Oak St.\nRoom 2024"
      minimum_elevation 757
      verbatim_latitude '40.091655'
      verbatim_longitude '-88.241413'
    end

    factory :collecting_event_point_c do
      verbatim_locality 'Champaign Co., Illinois'
      verbatim_label "City of Champaign"
      minimum_elevation 735 # ,
      verbatim_latitude '40.116402'
      verbatim_longitude '-88.243386'
    end

    factory :collecting_event_point_u do
      verbatim_locality 'Champaign Co., Illinois'
      verbatim_label "Urbana City Building"
      minimum_elevation 726 #,
      verbatim_latitude '40.110037'
      verbatim_longitude '-88.204517'
    end
  end
end

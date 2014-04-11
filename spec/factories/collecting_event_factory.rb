FactoryGirl.define do
  factory :collecting_event, traits: [:housekeeping] do

    factory :valid_collecting_event do
      verbatim_label "USA:TX:Brazos Co.\nCollege Station\nLick Creek Park\nii.15.1975 YPT"
    end

    factory :collecting_event_my_office do
      verbatim_label "USA:IL:Champaign Co.\nUniversity of Illinois\nResearch Park\nEvers Lab\n1909 S. Oak St.\nRoom 2024"
      minimum_elevation 757
      verbatim_latitude '40.091655'
      verbatim_longitude '-88.241413'
    end

    factory :collecting_event_point_c do
      verbatim_label "City of Champaign"
      minimum_elevation 735 # ,
      verbatim_latitude '40.116402'
      verbatim_longitude '-88.243386'
    end

    factory :collecting_event_point_u do
      verbatim_label "Urbana City Building"
      minimum_elevation 726 #,
      verbatim_latitude '40.110037'
      verbatim_longitude '-88.204517'
    end
  end
end

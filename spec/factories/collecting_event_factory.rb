FactoryGirl.define do
  factory :collecting_event, traits: [:housekeeping] do
    factory :valid_collecting_event do
      verbatim_label "USA:TX:Brazos Co.\nCollege Station\nLick Creek Park\nii.15.1975 YPT"
    end
  end
end

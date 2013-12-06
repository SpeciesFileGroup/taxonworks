FactoryGirl.define do
 factory :specimen, class: Specimen, traits: [:housekeeping] do
   factory :valid_specimen do
     total 1
   end
 end
end

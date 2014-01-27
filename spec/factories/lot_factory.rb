FactoryGirl.define do
 factory :lot, traits: [:housekeeping] do
   factory :valid_lot do
     total 10 
   end
 end
end

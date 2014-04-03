FactoryGirl.define do

  factory :georeference, traits: [:creator_and_updater] do

    factory :valid_georeference do

      collecting_event { FactoryGirl.build(:valid_collecting_event, 'Somebody\'s office')}

    end

    factory :point_georeference do

    end

  end

end

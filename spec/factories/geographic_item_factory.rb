FactoryGirl.define do

  factory :geographic_item, traits: [:creator_and_updater] do

    factory :geographic_item_with_point do
      #point @tw_factory.point(-88.241413, 40.091655)
    end

  end

end

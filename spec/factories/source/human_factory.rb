FactoryBot.define do
  factory :source_human, class: Source::Human, traits: [:creator_and_updater] do
    factory :valid_source_human do |source|

      after(:build) do |source|
        source.people << FactoryBot.create(:valid_person) 
      end
    end 
  end
end

FactoryBot.define do
  factory :field_occurrence, traits: [:housekeeping] do
    factory :valid_field_occurrence do
      total { 1 }
      association :collecting_event, factory: :valid_collecting_event
      is_absent { false }
      # valid_taxon_determination builds a Specimen - don't do that here
      #association :taxon_determination, factory: :valid_taxon_determination
      after(:build) do |parent|
        parent.taxon_determinations.build(
          otu: FactoryBot.build(:valid_otu),
          taxon_determination_object: parent
        )
      end
    end
  end
end

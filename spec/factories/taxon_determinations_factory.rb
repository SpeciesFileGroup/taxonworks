FactoryGirl.define do
  factory :taxon_determination, traits: [:housekeeping] do
    # TODO: this is valid now, but not for long
    factory :valid_taxon_determination
  end
end

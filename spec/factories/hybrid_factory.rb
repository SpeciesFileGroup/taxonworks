FactoryGirl.define do

  factory :hybrid, traits: [:housekeeping] do
    type 'Hybrid'
    name nil

    factory :valid_hybrid, traits: [:housekeeping] do
      association :parent, factory: :icn_genus
      year_of_publication 1850
      verbatim_author 'Say'
      rank_class Ranks.lookup(:icn, 'species')
      type 'Hybrid'
    end

  end
end
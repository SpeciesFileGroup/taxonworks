def root
  t = TaxonName.where(project_id: $project_id, parent_id: nil).limit(1).first
  t ? t : nil
end

FactoryGirl.define do
  factory :hybrid, traits: [:housekeeping] do
    name nil
    factory :valid_hybrid, traits: [:parent_is_root] do

      after(:create) do |hybrid|
        g = Protonym.create(name: 'Aus', rank_class: Ranks.lookup(:icn, :genus), parent: root)
        a = Protonym.create(name: 'cus', rank_class: Ranks.lookup(:icn, :species), parent: g)
        b = Protonym.create(name: 'dus', rank_class: Ranks.lookup(:icn, :species), parent: g)
        r1 = TaxonNameRelationship::Hybrid.create( subject_taxon_name: a, object_taxon_name: hybrid )
        r2 = TaxonNameRelationship::Hybrid.create( subject_taxon_name: b, object_taxon_name: hybrid )
      end 
    
      year_of_publication 1850
      verbatim_author 'Say'
      rank_class Ranks.lookup(:icn, 'species')
    end
  end
end

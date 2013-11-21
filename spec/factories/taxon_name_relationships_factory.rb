FactoryGirl.define do

  factory :taxon_name_relationship, class: 'TaxonNameRelationship' do
  end

  # TODO: over-ride parent so the cascading create doesn't happen
  factory :type_genus_relationship, class: 'TaxonNameRelationship' do
    association :subject, factory: :iczn_genus
    association :object, factory: :iczn_family
    type TaxonNameRelationship::Typification::Family
  end

  # TODO: over-ride parent so the cascading create doesn't happen
  factory :type_species_relationship, class: 'TaxonNameRelationship' do
    association :subject, factory: :iczn_species
    association :object, factory: :iczn_genus
    type TaxonNameRelationship::Typification::Genus::Monotypy::Original
  end



end

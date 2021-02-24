require 'rails_helper'
describe TaxonNameRelationship::Combination, type: :model, group: [:nomenclature]  do
  specify '.order_index' do
    genus_index = TaxonNameRelationship::Combination::Genus.order_index
    subgenus_index = TaxonNameRelationship::Combination::Subgenus.order_index
    expect(genus_index < subgenus_index).to be_truthy
  end

  specify '.rank_name' do
    expect(TaxonNameRelationship::Combination::Genus.rank_name).to eq('genus')
  end

  specify '#rank_name' do
    expect(TaxonNameRelationship::Combination::Genus.new.rank_name).to eq('genus')
  end

#  specify '.dijoint_classes' do
#    expect(TaxonNameRelationship::Combination::Genus.disjoint_classes).to include('TaxonNameClassification::Icn', 'TaxonNameClassification::Icn::EffectivelyPublished') # and many others
#  end

  specify '#object_status' do
    expect(TaxonNameRelationship::Combination::Genus.new.object_status).to eq('genus in combination')
  end

 specify '#subject_status' do
    expect(TaxonNameRelationship::Combination::Genus.new.subject_status).to eq(' as genus in combination')
  end




end

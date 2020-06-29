require 'rails_helper'

describe Queries::TaxonNameRelationship::Filter, type: :model, group: [:nomenclature] do

  let(:query) { Queries::TaxonNameRelationship::Filter.new({}) }

  let(:root) { FactoryBot.create(:root_taxon_name)}
  let(:f1) { Protonym.create!(name: 'Bidae', rank_class: Ranks.lookup(:iczn, 'family'), parent: root) }
  let(:g1) { Protonym.create!(name: 'Aus', rank_class: Ranks.lookup(:iczn, 'genus'), parent: root) }

  let!(:r1) { TaxonNameRelationship::SourceClassifiedAs.create!(subject_taxon_name: g1, object_taxon_name: f1) }

  specify '#taxon_name_id' do
    query.taxon_name_id = f1.id
    expect(query.all.map(&:id)).to contain_exactly(r1.id)
  end

  specify '#as_object' do
    query.taxon_name_id = f1.id
    query.as_object = true
    expect(query.all.map(&:id)).to contain_exactly(r1.id)
  end

  specify '#as_subject 1' do
    query.taxon_name_id = g1.id
    query.as_subject = true
    expect(query.all.map(&:id)).to contain_exactly(r1.id)
  end

  specify '#as_subject 2' do
    query.taxon_name_id = f1.id
    query.as_subject = true
    expect(query.all.map(&:id)).to contain_exactly()
  end

  specify '#taxon_name_relationship_type' do
    query.taxon_name_relationship_type = ['TaxonNameRelationship::SourceClassifiedAs']
    expect(query.all.map(&:id)).to contain_exactly(r1.id)
  end

  specify '#taxon_name_relationship_set' do
    query.taxon_name_relationship_set = ['classification']
    expect(query.all.map(&:id)).to contain_exactly(r1.id)
  end

# specify 'all filters combined' do
#   expect(query.all.map(&:id)).to contain_exactly(species.id)
# end

end

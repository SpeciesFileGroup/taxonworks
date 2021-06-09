require 'rails_helper'

describe Queries::TaxonNameClassification::Filter, type: :model, group: [:nomenclature] do

  let(:query) { Queries::TaxonNameClassification::Filter.new({}) }

  let(:root) { FactoryBot.create(:root_taxon_name)}
  let(:f1) { Protonym.create!(name: 'Bidae', rank_class: Ranks.lookup(:iczn, 'family'), parent: root) }
  let(:g1) { Protonym.create!(name: 'Aus', rank_class: Ranks.lookup(:iczn, 'genus'), parent: root) }

  let!(:c1) { TaxonNameClassification::Iczn::Unavailable.create!(taxon_name: g1) }

  specify '#taxon_name_id 1' do
    query.taxon_name_id = g1.id
    expect(query.all.map(&:id)).to contain_exactly(c1.id)
  end

  specify '#taxon_name_id 2' do
    query.taxon_name_id = [g1.id]
    expect(query.all.map(&:id)).to contain_exactly(c1.id)
  end

  specify '#taxon_name_classification_type 1' do
    query.taxon_name_classification_type = ['TaxonNameClassification::Iczn::Unavailable']
    expect(query.all.map(&:id)).to contain_exactly(c1.id)
  end

  specify '#taxon_name_classification_type 2' do
    query.taxon_name_classification_type = 'TaxonNameClassification::Iczn::Unavailable'
    expect(query.all.map(&:id)).to contain_exactly(c1.id)
  end

  specify '#taxon_name_classification_set 1' do
    query.taxon_name_classification_set = 'invalidating'
    expect(query.all.map(&:id)).to contain_exactly(c1.id)
  end

end

require 'rails_helper'

describe Queries::TaxonName::Filter, type: :model, group: [:nomenclature] do

  let(:query) { Queries::TaxonName::Filter.new({}) }

  let(:root) { FactoryBot.create(:root_taxon_name)}
  let(:genus) { Protonym.create(name: 'Erasmoneura', rank_class: Ranks.lookup(:iczn, 'genus'), parent: root) }
  let(:original_genus) { Protonym.create(name: 'Bus', rank_class: Ranks.lookup(:iczn, 'genus'), parent: root) }
  let!(:species) { Protonym.create!(
    name: 'vulnerata',
    rank_class: Ranks.lookup(:iczn, 'species'),
    parent: genus,
    original_genus: original_genus,
    verbatim_author: 'Fitch & Say',
    year_of_publication: 1800) }

  specify '#name' do
    query.name = 'vulner' 
    expect(query.all.map(&:id)).to contain_exactly(species.id)
  end

  specify '#name, #exact' do
    query.name = 'vulnerata' 
    query.exact = true
    expect(query.all.map(&:id)).to contain_exactly()
  end

  specify '#author' do
    query.author = 'Fitch & S' 
    expect(query.all.map(&:id)).to contain_exactly(species.id)
  end

  specify '#author, #exact' do
    query.author = 'Fit'
    query.exact = true 
    expect(query.all.map(&:id)).to contain_exactly()
  end

end

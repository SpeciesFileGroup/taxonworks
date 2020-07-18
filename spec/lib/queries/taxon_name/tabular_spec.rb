require 'rails_helper'

describe Queries::TaxonName::Tabular, type: :model, group: [:nomenclature] do
  let(:root) { FactoryBot.create(:root_taxon_name) }
  let(:genus) { Protonym.create!(name: 'Erasmoneura', rank_class: Ranks.lookup(:iczn, :genus), parent: root) }
  let!(:species1) { Protonym.create!(name: 'alpha', rank_class: Ranks.lookup(:iczn, :species), parent: genus) }
  let!(:species2) { Protonym.create!(name: 'betta', rank_class: Ranks.lookup(:iczn, :species), parent: genus) }

  let(:query) { Queries::TaxonName::Tabular.new } 

  specify '#number_of_species' do
    query.ancestor_id = genus.id.to_s 
    query.ranks = ['genus', 'species']
    query.rank_data =  ['genus', 'species']
    query.fieldsets = ['nomenclatural_stats']
    query.validity = true
    
    query.build_query
    expect(query.all.first['valid_species']).to eq(2)
  end

end

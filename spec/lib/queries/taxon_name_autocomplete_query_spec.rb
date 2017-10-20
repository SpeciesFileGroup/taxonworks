require 'rails_helper'

describe Queries::TaxonNameAutocompleteQuery, type: :model do

  let(:root) { FactoryGirl.create(:root_taxon_name)}
  let(:genus) { Protonym.create(name: 'Erasmoneura', rank_class: Ranks.lookup(:iczn, 'genus'), parent: root) }
  let!(:species) { Protonym.create(name: 'vulnerata', rank_class: Ranks.lookup(:iczn, 'species'), parent: genus) }

  let(:name) { 'Erasmoneura vulnerata' }

  let(:query) { Queries::TaxonNameAutocompleteQuery.new('') }

 
  # some patterns - 

  specify '#autocomplete_top_name 1' do
    query.terms = 'vulnerata' 
    expect(query.autocomplete_top_name.first).to eq(species)
  end

  specify '#autocomplete_top_name 2' do
    query.terms = 'Erasmoneura' 
    expect(query.autocomplete.first).to eq(genus) 
  end

  specify '#autocomplete_top_cached' do
    query.terms = name 
    expect(query.autocomplete).to include(species) 
  end

  # etc. ---

end

require 'rails_helper'

describe Queries::TaxonNameAutocompleteQuery, type: :model do

  let(:root) { FactoryGirl.create(:root_taxon_name)}
  let(:genus) { Protonym.create(name: 'Erasmoneura', rank_class: Ranks.lookup(:iczn, 'genus'), parent: root) }
  let!(:species) { Protonym.create(name: 'vulnerata', rank_class: Ranks.lookup(:iczn, 'species'), parent: genus, verbatim_author: 'Fitch & Say', year_of_publication: 1800) }

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

  specify '#autocomplete_top_name 3' do
    query.terms = 'Erasmon'
    expect(query.autocomplete.first).to eq(genus)
  end

  specify '#autocomplete_top_cached 4' do
    query.terms = 'vuln'
    expect(query.autocomplete).to include(species)
  end

  specify '#autocomplete_top_name 5' do
    query.terms = 'rasmon'
    expect(query.autocomplete.first).to eq(genus)
  end

  specify '#autocomplete_top_name 6' do
    query.terms = 'ulner'
    expect(query.autocomplete.first).to eq(species)
  end

  specify '#autocomplete_top_name 7' do
    query.terms = 'neur nerat'
    expect(query.autocomplete.first).to eq(species)
  end

  specify '#autocomplete_top_name 8' do
    query.terms = 'E vul'
    expect(query.autocomplete.first).to eq(species)
  end

  specify '#autocomplete_top_name 9' do
    query.terms = 'E. vul'
    expect(query.autocomplete.first).to eq(species)
  end

  specify '#autocomplete_top_name 10' do
    query.terms = 'Fitch'
    expect(query.autocomplete.first).to eq(species)
  end

  specify '#autocomplete_top_name 11' do
    query.terms = 'Say'
    expect(query.autocomplete.first).to eq(species)
  end

  specify '#autocomplete_top_name 12' do
    query.terms = '1800'
    expect(query.autocomplete.first).to eq(species)
  end

  specify '#autocomplete_top_name 13' do
    query.terms = 'Fitch 1800'
    expect(query.autocomplete.first).to eq(species)
  end


  # etc. ---

end

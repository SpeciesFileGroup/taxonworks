require 'rails_helper'

describe TaxonNamesHelper, type: :helper do
  let(:taxon_name) {FactoryBot.create(:valid_protonym) }

  specify '#taxon_name_autocomplete_tag 1' do
    expect(taxon_name_autocomplete_tag(taxon_name, 'Aus (')).to be_truthy
  end

  specify '#taxon_name_for_select' do
    expect(taxon_name_for_select(taxon_name)).to eq('Aaidae')
  end

  specify '#parent_taxon_name_for_select' do
    expect(parent_taxon_name_for_select(taxon_name)).to eq('Root')
  end

  specify '#taxon_name_tag' do
    expect(taxon_name_tag(taxon_name)).to eq('Aaidae')
  end

  specify '#taxon_name_link' do
    expect(taxon_name_link(taxon_name)).to have_link('Aaidae')
  end

  specify '#taxon_name_rank_select_tag' do
    expect(taxon_name_rank_select_tag(taxon_name: taxon_name, code: :iczn)).to have_select('taxon_name_rank_class')
  end
end

require 'rails_helper'

describe Queries::DwcOccurrence::Filter, type: :model, group: [:dwc_occurrence] do
  let(:query) { Queries::DwcOccurrence::Filter.new({}) }

  specify '#initialize' do
    expect(Queries::DwcOccurrence::Filter.new({})).to be_truthy
  end

  specify '#collection_object_query' do
    a = Specimen.create!
    Specimen.create!

    b = ::Queries::CollectionObject::Filter.new(collection_object_id: a.id)

    query.collection_object_query = b

    expect(query.all).to contain_exactly(a.dwc_occurrence)
  end

  specify '#year' do
    c = FactoryBot.create(:valid_collecting_event, start_date_year: '1920')
    s = Specimen.create!(collecting_event: c)
    Specimen.create!()

    query.year = '1920'
    expect(query.all.first.dwc_occurrence_object).to eq(s)
  end

  specify '#empty_rank' do
    s = Specimen.create!()
    t = FactoryBot.create(:valid_taxon_determination, taxon_determination_object: s)
    n = FactoryBot.create(:iczn_species)
    t.otu.update!(taxon_name: n.parent.parent)
    query.empty_rank = [ t.otu.taxon_name.rank_name ]
    expect(query.all).to be_empty
  end

   specify '#empty_rank' do
    s = Specimen.create!()
    t = FactoryBot.create(:valid_taxon_determination, taxon_determination_object: s)
    n = FactoryBot.create(:iczn_family)
    t.otu.update!(taxon_name: n.parent.parent)
    query.empty_rank = [ 'genus' ]
    expect(query.all).to contain_exactly(s.dwc_occurrence)
  end

   specify '#empty_rank' do
    s = Specimen.create!()
    t = FactoryBot.create(:valid_taxon_determination, taxon_determination_object: s)
    n = FactoryBot.create(:iczn_family)
    t.otu.update!(taxon_name: n.parent.parent)
    query.empty_rank = [ 'genus', 'specificEpithet' ]
    expect(query.all).to contain_exactly(s.dwc_occurrence)
  end

end

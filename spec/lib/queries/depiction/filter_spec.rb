require 'rails_helper'

describe Queries::Depiction::Filter, type: :model, group: :depictions do

  let!(:o) { FactoryBot.create(:valid_otu) }
  let!(:s) { FactoryBot.create(:valid_specimen) }
  let!(:c) { FactoryBot.create(:valid_collecting_event) }

  let!(:d1) { FactoryBot.create(:valid_depiction, depiction_object: o) } 
  let!(:d2) { FactoryBot.create(:valid_depiction, depiction_object: s) } 

  let(:query) { Queries::Depiction::Filter.new({}) }

  specify '#depiction_object_type' do
    query.depiction_object_type = 'Otu'
    expect(query.all.map(&:id)).to contain_exactly(d1.id)
  end

  specify '#depiction_object_types' do
    query.depiction_object_types = ['Otu', 'CollectionObject']
    expect(query.all.map(&:id)).to contain_exactly(d1.id, d2.id)
  end

  specify '#sqed_depiction 1' do
    query.depiction_object_type = 'Otu'
    query.sqed_depiction = true
    expect(query.all.map(&:id)).to contain_exactly()
  end

  specify '#sqed_depiction 2' do
    FactoryBot.create(:valid_sqed_depiction, depiction: d1)
    query.sqed_depiction = true
    expect(query.all.map(&:id)).to contain_exactly(d1.id)
  end

end

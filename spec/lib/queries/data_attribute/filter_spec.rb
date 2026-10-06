require 'rails_helper'

describe Queries::DataAttribute::Filter, type: :model do

  let(:o1) { FactoryBot.create(:valid_otu) }
  let(:o2) { FactoryBot.create(:valid_specimen) }
  let(:o3) { FactoryBot.create(:valid_collecting_event) }

  let(:p1) { FactoryBot.create(:valid_controlled_vocabulary_term_predicate) }
  let(:p2) { FactoryBot.create(:valid_controlled_vocabulary_term_predicate) }

  let!(:i1) { ::InternalAttribute.create!(attribute_subject: o1, value: 'x', predicate: p1) }
  let!(:i2) { ::InternalAttribute.create!(attribute_subject: o2, value: 'y', predicate: p2) }
  let!(:i3) { ::InternalAttribute.create!(attribute_subject: o3, value: 'z', predicate: p2) }

  let(:query) { Queries::DataAttribute::Filter.new({}) }

  specify '#otu_query_facet' do
    q = Queries::DataAttribute::Filter.new(otu_query: { otu_id: [o1.id] })
    expect(q.all).to contain_exactly(i1)
  end

  specify '#collection_object_query_facet' do
    q = Queries::DataAttribute::Filter.new(collection_object_query: { collection_object_id: [o2.id] })
    expect(q.all).to contain_exactly(i2)
  end

  specify '#collecting_event_query_facet' do
    q = Queries::DataAttribute::Filter.new(collecting_event_query: { collecting_event_id: [o3.id] })
    expect(q.all).to contain_exactly(i3)
  end

  specify '#polymorphic_id_facet' do
    h = {collection_object_id: o2.id} 
    q = Queries::DataAttribute::Filter.new(h)
    expect(q.all).to contain_exactly(i2)
  end

  specify '#polymorphic_id' do
    h = {collection_object_id: o2.id} 
    q = Queries::DataAttribute::Filter.new(h)
    expect(q.polymorphic_type).to eq('CollectionObject')
  end

  specify '#polymorphic_id' do
    h = {collection_object_id: o2.id} 
    q = Queries::DataAttribute::Filter.new(h)
    expect(q.polymorphic_id).to eq(o2.id)
  end

  specify 'polymorphic params handling' do
    h = {collection_object_id: o2.id} 
    q = Queries::DataAttribute::Filter.new(h)
    expect(q.permitted_params(h)).to include(:collection_object_id)
  end

  specify 'generic query' do
    query.controlled_vocabulary_term_id = p1.id
    expect(query.all).to contain_exactly(i1)
  end

  specify '#object_global_id' do
    query.object_global_id = i1.to_global_id.to_s
    expect(query.all).to contain_exactly(i1)
  end

  specify '#asserted_environment_query_facet' do
    ae = FactoryBot.create(:valid_asserted_environment)
    other_ae = FactoryBot.create(:valid_asserted_environment)
    da = ::InternalAttribute.create!(attribute_subject: ae, value: 'ae', predicate: p1)
    ::InternalAttribute.create!(attribute_subject: other_ae, value: 'other', predicate: p1)

    q = Queries::DataAttribute::Filter.new(asserted_environment_query: { asserted_environment_id: [ae.id] })
    expect(q.all).to contain_exactly(da)
  end

  specify '#lead_query_facet' do
    key = FactoryBot.create(:valid_lead)
    other_key = FactoryBot.create(:valid_lead, text: 'Other key')
    da = ::InternalAttribute.create!(attribute_subject: key, value: 'adult', predicate: p1)
    ::InternalAttribute.create!(attribute_subject: other_key, value: 'nymph', predicate: p1)

    q = Queries::DataAttribute::Filter.new(lead_query: { lead_id: [key.id] })
    expect(q.all).to contain_exactly(da)
  end
end

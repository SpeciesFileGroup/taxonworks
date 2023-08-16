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

end

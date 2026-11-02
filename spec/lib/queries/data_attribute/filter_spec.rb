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

  specify '#from_filter_facet' do
    q = ::Queries::Otu::Filter.new(otu_id: o1.id)
   
    a = Queries::DataAttribute::Filter.new(otu_query: q.params)
    expect(a.from_filter_facet(q)).to contain_exactly(i1)
  end

  # Any filter whose referenced model has data attributes can be the scope for a
  # data attribute batch update; an unregistered *_query raises, so the batch
  # annotator would fail for that model.
  specify 'every subqueryable model with data attributes is a DataAttribute subquery' do
    a = ::Queries::Query::Filter::FILTER_QUERIES.select { |k, v|
      v.constantize.referenced_klass.included_modules.include?(::Shared::DataAttributes)
    }.keys.map { |k| k.to_s.sub(/_query\z/, '').to_sym }

    expect(::Queries::Query::Filter::SUBQUERIES[:data_attribute]).to contain_exactly(*a)
  end

  context 'each DataAttribute subquery scopes to its records' do
    factories = { source: :valid_source_bibtex }

    ::Queries::Query::Filter::SUBQUERIES[:data_attribute].each do |m|
      specify m.to_s do
        f = factories[m] || "valid_#{m}".to_sym
        in_scope, out_of_scope = FactoryBot.create(f), FactoryBot.create(f)

        da1 = ::InternalAttribute.create!(attribute_subject: in_scope, value: 'a', predicate: p1)
        ::InternalAttribute.create!(attribute_subject: out_of_scope, value: 'a', predicate: p1)

        q = Queries::DataAttribute::Filter.new("#{m}_query".to_sym => { "#{m}_id".to_sym => [in_scope.id] })
        expect(q.all).to contain_exactly(da1)
      end
    end
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

end

require 'rails_helper'

RSpec.describe ProtocolRelationship, type: :model, group: :protocol do
  include ActiveJob::TestHelper

  let(:protocol_relationship) { ProtocolRelationship.new }
  let(:protocol) { FactoryBot.create(:valid_protocol) }
  let(:specimen) { Specimen.create! }

  specify '#batch_by_filter_scope :replace, async, ' do
    c1 = FactoryBot.create(:valid_protocol_relationship)
    ProtocolRelationship.create!(protocol_relationship_object: specimen, protocol:)

    q = ::Queries::CollectionObject::Filter.new(collection_object_id: specimen.id)
    p = ActionController::Parameters.new( { 'collection_object_query' => q.params })

    ProtocolRelationship.batch_by_filter_scope(
      filter_query: p,
      mode: :replace,
      async_cutoff: 0,
      protocol_id: c1.id,
      replace_protocol_id: protocol_relationship.id
    )

    perform_enqueued_jobs

    expect(ProtocolRelationship.all.first.protocol_id).to eq(c1.id)
  end

  specify '#batch_by_filter_scope :replace, async' do
    c1 = FactoryBot.create(:valid_protocol_relationship)

    ProtocolRelationship.create!(protocol_relationship_object: specimen, protocol:)

    q = ::Queries::CollectionObject::Filter.new(collection_object_id: specimen.id)
    ProtocolRelationship.batch_by_filter_scope(
      filter_query: { 'collection_object_query' => q.params },
      mode: :replace,
      async_cutoff: 0,
      protocol_id: c1.id,
      replace_protocol_id: protocol_relationship.id
    )

    perform_enqueued_jobs

    expect(ProtocolRelationship.all.first.protocol_id).to eq(c1.id)
  end

  specify '#batch_by_filter_scope :replace' do
    c1 = FactoryBot.create(:valid_protocol_relationship)
    ProtocolRelationship.create!(protocol_relationship_object: specimen, protocol:)
    q = ::Queries::CollectionObject::Filter.new(collection_object_id: specimen.id)
    ProtocolRelationship.batch_by_filter_scope(
      filter_query: { 'collection_object_query' => q.params },
      mode: :replace,
      protocol_id: c1.id,
      replace_protocol_id: protocol_relationship.id
    )
    expect(ProtocolRelationship.all.first.protocol_id).to eq(c1.id)
  end

  # No async test, we don't use
  specify '#batch_by_filter_scope :remove' do
    ProtocolRelationship.create!(protocol_relationship_object: specimen, protocol:)
    q = ::Queries::CollectionObject::Filter.new(collection_object_id: specimen.id)
    ProtocolRelationship.batch_by_filter_scope(
      filter_query: { 'collection_object_query' => q.params },
      mode: :remove,
      protocol_id: protocol_relationship.id)
    expect(ProtocolRelationship.all.count).to eq(0)
  end

  specify '#batch_by_filter_scope :add' do
    q = ::Queries::CollectionObject::Filter.new(collection_object_id: specimen.id)
    ProtocolRelationship.batch_by_filter_scope(
      filter_query: { 'collection_object_query' => q.params },
      mode: :add,
      protocol_id: protocol.id)
    expect(ProtocolRelationship.all.count).to eq(1)
  end

  specify '#batch_by_filter_scope :add, async' do
    q = ::Queries::CollectionObject::Filter.new(collection_object_id: specimen.id)
    ProtocolRelationship.batch_by_filter_scope(
      filter_query: { 'collection_object_query' => q.params },
      mode: :add,
      protocol_id: protocol.id,
      async_cutoff: 0)
    expect(ProtocolRelationship.all.count).to eq(0)

    perform_enqueued_jobs

    expect(ProtocolRelationship.all.count).to eq(1)
  end

  context 'validations' do
    specify 'protocol_id' do
      protocol_relationship.valid?
      expect(protocol_relationship.errors.include?(:protocol)).to be_truthy
    end

    specify '#protocol_relationship_object_type' do
      protocol_relationship.protocol = protocol
      protocol_relationship.protocol_relationship_object_id = 1
      protocol_relationship.valid?
      expect(protocol_relationship.errors.include?(:protocol_relationship_object)).to be_truthy
    end

    specify '#protocol_relationship_object_id' do
      protocol_relationship.protocol = protocol
      protocol_relationship.protocol_relationship_object_type = 'Image'
      protocol_relationship.valid?
      expect(protocol_relationship.errors.include?(:protocol_relationship_object)).to be_truthy
    end

    specify 'protocol_id and protocol_relationship_object_id and protocol_relationship_object_type' do
      expect(FactoryBot.build(:valid_protocol_relationship).valid?).to be_truthy
    end
  end
end

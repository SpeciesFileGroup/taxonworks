require 'rails_helper'

RSpec.describe Confidence, type: :model, group: :confidence do
  include ActiveJob::TestHelper

  let(:confidence) { Confidence.new }
  let(:confidence_level) { FactoryBot.create(:valid_confidence_level) }
  let(:specimen) { FactoryBot.create(:valid_specimen) }

  specify '#batch_by_filter_scope :replace, async, ' do
    c1 = FactoryBot.create(:valid_confidence_level)
    Confidence.create!(confidence_object: specimen, confidence_level:)

    q = ::Queries::CollectionObject::Filter.new(collection_object_id: specimen.id)
    p = ActionController::Parameters.new( { 'collection_object_query' => q.params })

    Confidence.batch_by_filter_scope(
      filter_query: p,
      mode: :replace,
      async_cutoff: 0,
      confidence_level_id: c1.id,
      replace_confidence_level_id: confidence_level.id
    )

    # expect { ConfidenceBatchJob.perform_later }.to have_enqueued_job.on_queue(:query_batch_update)
    perform_enqueued_jobs

    expect(Confidence.all.first.confidence_level_id).to eq(c1.id)
  end

  specify '#batch_by_filter_scope :replace, async' do
    c1 = FactoryBot.create(:valid_confidence_level)

    Confidence.create!(confidence_object: specimen, confidence_level:)

    q = ::Queries::CollectionObject::Filter.new(collection_object_id: specimen.id)
    Confidence.batch_by_filter_scope(
      filter_query: { 'collection_object_query' => q.params },
      mode: :replace,
      async_cutoff: 0,
      confidence_level_id: c1.id,
      replace_confidence_level_id: confidence_level.id
    )

    # expect { ConfidenceBatchJob.perform_later }.to have_enqueued_job.on_queue(:query_batch_update)
    perform_enqueued_jobs

    expect(Confidence.all.first.confidence_level_id).to eq(c1.id)
  end

  specify '#batch_by_filter_scope :replace' do
    c1 = FactoryBot.create(:valid_confidence_level)
    Confidence.create!(confidence_object: specimen, confidence_level:)
    q = ::Queries::CollectionObject::Filter.new(collection_object_id: specimen.id)
    Confidence.batch_by_filter_scope(
      filter_query: { 'collection_object_query' => q.params },
      mode: :replace,
      confidence_level_id: c1.id,
      replace_confidence_level_id: confidence_level.id
    )
    expect(Confidence.all.first.confidence_level_id).to eq(c1.id)
  end

  # No async test, we don't use
  specify '#batch_by_filter_scope :remove' do
    Confidence.create!(confidence_object: specimen, confidence_level:)
    q = ::Queries::CollectionObject::Filter.new(collection_object_id: specimen.id)
    Confidence.batch_by_filter_scope(
      filter_query: { 'collection_object_query' => q.params },
      mode: :remove,
      confidence_level_id: confidence_level.id)
    expect(Confidence.all.count).to eq(0)
  end

  specify '#batch_by_filter_scope :add' do
    q = ::Queries::CollectionObject::Filter.new(collection_object_id: specimen.id)
    Confidence.batch_by_filter_scope(
      filter_query: { 'collection_object_query' => q.params },
      mode: :add,
      confidence_level_id: confidence_level.id)
    expect(Confidence.all.count).to eq(1)
  end

  specify '#batch_by_filter_scope :add, async' do
    q = ::Queries::CollectionObject::Filter.new(collection_object_id: specimen.id)
    Confidence.batch_by_filter_scope(
      filter_query: { 'collection_object_query' => q.params },
      mode: :add,
      confidence_level_id: confidence_level.id,
      async_cutoff: 0)
    expect(Confidence.all.count).to eq(0)

    perform_enqueued_jobs

    expect(Confidence.all.count).to eq(1)
  end

  context 'validation' do
    before { confidence.save }

    specify 'confidence_level_id' do
      expect(confidence.errors.include?(:confidence_level)).to be_truthy
    end
  end

  context 'associations' do
    specify '#confidence_level' do
      expect(confidence.confidence_level = ConfidenceLevel.new()).to be_truthy
    end

    specify '#confidence_object' do
      expect(confidence.confidence_object = Specimen.new()).to be_truthy
    end
  end

  specify '#annotated_global_entity' do
    confidence.annotated_global_entity = specimen.to_global_id.to_s
    confidence.confidence_level_id = confidence_level.id
    expect(confidence.save!).to be_truthy
  end

end
